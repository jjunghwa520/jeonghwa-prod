#!/usr/bin/env node

const { Server } = require('@modelcontextprotocol/sdk/dist/cjs/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/dist/cjs/server/stdio.js');
const { exec } = require('child_process');
const { promisify } = require('util');
const path = require('path');
const fs = require('fs').promises;

const execAsync = promisify(exec);
const PROJECT_ROOT = process.env.CURSOR_WORKSPACE || '/Users/l2dogyu/KICDA/ruby/kicda-jh';

class RailsMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'rails-mcp',
        version: '1.0.0',
        description: 'Rails development MCP server for KICDA project'
      },
      {
        capabilities: {
          tools: {},
          resources: {}
        }
      }
    );
    
    this.setupHandlers();
  }

  setupHandlers() {
    // Tools list
    this.server.setRequestHandler('tools/list', async () => ({
      tools: [
        {
          name: 'rails_generate',
          description: 'Generate Rails code (model, controller, etc)',
          inputSchema: {
            type: 'object',
            properties: {
              generator: { type: 'string', enum: ['model', 'controller', 'scaffold', 'migration', 'job', 'mailer'] },
              name: { type: 'string' },
              attributes: { type: 'string' }
            },
            required: ['generator', 'name']
          }
        },
        {
          name: 'claude_cli',
          description: 'Run Claude CLI (SuperClaude) with optional MCP and workspace',
          inputSchema: {
            type: 'object',
            properties: {
              prompt: { type: 'string', description: 'Prompt to send to Claude CLI' },
              mcp: { type: 'string', description: 'MCP server name to use (optional)' },
              workspace: { type: 'string', description: 'Workspace name (optional)' },
              flags: { type: 'string', description: 'Additional flags passed to CLI (optional)' }
            },
            required: ['prompt']
          }
        },
        {
          name: 'rails_db',
          description: 'Database operations',
          inputSchema: {
            type: 'object',
            properties: {
              command: { type: 'string', enum: ['migrate', 'rollback', 'seed', 'reset', 'create', 'drop'] }
            },
            required: ['command']
          }
        },
        {
          name: 'rails_test',
          description: 'Run tests',
          inputSchema: {
            type: 'object',
            properties: {
              file: { type: 'string' },
              type: { type: 'string', enum: ['all', 'unit', 'functional', 'integration'] }
            }
          }
        },
        {
          name: 'rails_routes',
          description: 'Show routes',
          inputSchema: {
            type: 'object',
            properties: {
              grep: { type: 'string' }
            }
          }
        },
        {
          name: 'bundle',
          description: 'Bundle operations',
          inputSchema: {
            type: 'object',
            properties: {
              command: { type: 'string', enum: ['install', 'update', 'add'] },
              gem: { type: 'string' }
            },
            required: ['command']
          }
        },
        {
          name: 'git',
          description: 'Git operations',
          inputSchema: {
            type: 'object',
            properties: {
              command: { type: 'string', enum: ['status', 'add', 'commit', 'push', 'pull'] },
              message: { type: 'string' },
              files: { type: 'string' }
            },
            required: ['command']
          }
        },
        {
          name: 'ai_assistant',
          description: 'AI Development Assistant',
          inputSchema: {
            type: 'object',
            properties: {
              intent: { type: 'string', description: 'What you want to build' }
            },
            required: ['intent']
          }
        }
      ]
    }));

    // Tool execution
    this.server.setRequestHandler('tools/call', async (request) => {
      const { name, arguments: args } = request.params;
      
      try {
        switch(name) {
          case 'rails_generate':
            return await this.railsGenerate(args);
          case 'claude_cli':
            return await this.claudeCli(args);
          case 'rails_db':
            return await this.railsDb(args);
          case 'rails_test':
            return await this.railsTest(args);
          case 'rails_routes':
            return await this.railsRoutes(args);
          case 'bundle':
            return await this.bundle(args);
          case 'git':
            return await this.git(args);
          case 'ai_assistant':
            return await this.aiAssistant(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [{
            type: 'text',
            text: `Error: ${error.message}`
          }]
        };
      }
    });

    // Resources
    this.server.setRequestHandler('resources/list', async () => ({
      resources: [
        {
          uri: 'rails://schema',
          name: 'Database Schema',
          mimeType: 'text/plain'
        },
        {
          uri: 'rails://routes',
          name: 'Routes',
          mimeType: 'text/plain'
        },
        {
          uri: 'rails://gemfile',
          name: 'Gemfile',
          mimeType: 'text/plain'
        }
      ]
    }));

    this.server.setRequestHandler('resources/read', async (request) => {
      const { uri } = request.params;
      
      switch(uri) {
        case 'rails://schema':
          const schema = await fs.readFile(path.join(PROJECT_ROOT, 'db/schema.rb'), 'utf-8');
          return { contents: [{ uri, mimeType: 'text/plain', text: schema }] };
        
        case 'rails://routes':
          const { stdout } = await execAsync(`cd ${PROJECT_ROOT} && rails routes`);
          return { contents: [{ uri, mimeType: 'text/plain', text: stdout }] };
        
        case 'rails://gemfile':
          const gemfile = await fs.readFile(path.join(PROJECT_ROOT, 'Gemfile'), 'utf-8');
          return { contents: [{ uri, mimeType: 'text/plain', text: gemfile }] };
        
        default:
          throw new Error(`Unknown resource: ${uri}`);
      }
    });
  }

  async railsGenerate(args) {
    const { generator, name, attributes } = args;
    const cmd = `rails generate ${generator} ${name} ${attributes || ''}`;
    const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${cmd}`);
    
    // Auto-migrate if model or scaffold
    if (generator === 'model' || generator === 'scaffold') {
      await execAsync(`cd ${PROJECT_ROOT} && rails db:migrate`);
    }
    
    return {
      content: [{
        type: 'text',
        text: `Generated ${generator} ${name}\n${stdout}\n${stderr}`
      }]
    };
  }

  async claudeCli(args) {
    const { prompt, mcp, workspace, flags } = args;
    const SUPERCLAUDE_BIN = process.env.SUPERCLAUDE_BIN || '/opt/homebrew/bin/superclaude';
    // 기본적으로 존재하지 않을 수 있으므로 npx 경로도 시도하도록 구성
    // 단, 실제 실행은 여기서 하지 않고, 명령 문자열만 구성하여 반환
    let cmd = SUPERCLAUDE_BIN;
    if (workspace) cmd += ` --workspace ${workspace}`;
    if (mcp) cmd += ` --mcp ${mcp}`;
    if (flags) cmd += ` ${flags}`;
    // 프롬프트 안전한 인용 처리
    const escapedPrompt = String(prompt).replace(/"/g, '\\"');
    cmd += ` "${escapedPrompt}"`;
    
    // 실행 및 결과 반환
    const { stdout, stderr } = await execAsync(cmd).catch(async (err) => {
      // SUPERCLAUDE_BIN 경로 실패 시 npx 경로로 폴백 시도
      const npxCmd = `/opt/homebrew/bin/npx superclaude${workspace ? ` --workspace ${workspace}` : ''}${mcp ? ` --mcp ${mcp}` : ''}${flags ? ` ${flags}` : ''} "${escapedPrompt}"`;
      try {
        const { stdout: s2, stderr: e2 } = await execAsync(npxCmd);
        return { stdout: s2, stderr: e2 };
      } catch (err2) {
        return { stdout: '', stderr: `Failed to run Claude CLI. Tried: ${cmd} and ${npxCmd}. Error: ${err2.message}` };
      }
    });
    
    return {
      content: [{
        type: 'text',
        text: `Claude CLI output (prompt: ${prompt.substring(0, 60)}${prompt.length > 60 ? '...' : ''})\n${stdout}\n${stderr}`
      }]
    };
  }

  async railsDb(args) {
    const { command } = args;
    const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && rails db:${command}`);
    return {
      content: [{
        type: 'text',
        text: `Database ${command} completed\n${stdout}\n${stderr}`
      }]
    };
  }

  async railsTest(args) {
    const { file, type } = args;
    let cmd = 'rails test';
    if (file) cmd += ` ${file}`;
    else if (type && type !== 'all') cmd += `:${type}`;
    
    const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${cmd}`);
    return {
      content: [{
        type: 'text',
        text: `Test results:\n${stdout}\n${stderr}`
      }]
    };
  }

  async railsRoutes(args) {
    const { grep } = args;
    let cmd = 'rails routes';
    if (grep) cmd += ` | grep ${grep}`;
    
    const { stdout } = await execAsync(`cd ${PROJECT_ROOT} && ${cmd}`);
    return {
      content: [{
        type: 'text',
        text: stdout
      }]
    };
  }

  async bundle(args) {
    const { command, gem } = args;
    let cmd = `bundle ${command}`;
    if (command === 'add' && gem) cmd += ` ${gem}`;
    
    const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${cmd}`);
    return {
      content: [{
        type: 'text',
        text: `Bundle ${command} completed\n${stdout}\n${stderr}`
      }]
    };
  }

  async git(args) {
    const { command, message, files } = args;
    let cmd = `git ${command}`;
    
    if (command === 'add' && files) cmd += ` ${files}`;
    else if (command === 'add' && !files) cmd += ' .';
    else if (command === 'commit' && message) cmd += ` -m "${message}"`;
    
    const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${cmd}`);
    return {
      content: [{
        type: 'text',
        text: `Git ${command} completed\n${stdout}\n${stderr}`
      }]
    };
  }

  async aiAssistant(args) {
    const { intent } = args;
    const script = `
      require Rails.root.join('lib', 'ai_development_assistant')
      assistant = AIDevelopmentAssistant.new
      result = assistant.execute_intent("${intent}")
      puts result.to_json
    `;
    
    const tmpFile = `/tmp/ai_assistant_${Date.now()}.rb`;
    await fs.writeFile(tmpFile, script);
    
    const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && rails runner ${tmpFile}`);
    await fs.unlink(tmpFile);
    
    return {
      content: [{
        type: 'text',
        text: `AI Assistant Result:\n${stdout}\n${stderr}`
      }]
    };
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Rails MCP Server started');
  }
}

// Start server
const server = new RailsMCPServer();
server.start().catch(console.error);
