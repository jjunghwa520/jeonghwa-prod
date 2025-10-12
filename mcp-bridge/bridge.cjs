#!/usr/bin/env node

const { StdioServerTransport } = require('@modelcontextprotocol/sdk/dist/cjs/server/stdio.js');
const { Server } = require('@modelcontextprotocol/sdk/dist/cjs/server/index.js');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);
const PROJECT_ROOT = '/Users/l2dogyu/KICDA/ruby/kicda-jh';

// Create server
const server = new Server(
  {
    name: 'kicda-bridge',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'run_command',
      description: 'Run a shell command in the project directory',
      inputSchema: {
        type: 'object',
        properties: {
          command: {
            type: 'string',
            description: 'The command to run',
          },
        },
        required: ['command'],
      },
    },
    {
      name: 'rails_command',
      description: 'Run a Rails command',
      inputSchema: {
        type: 'object',
        properties: {
          command: {
            type: 'string',
            description: 'Rails command (e.g., generate model User name:string)',
          },
        },
        required: ['command'],
      },
    },
    {
      name: 'project_status',
      description: 'Check project status',
      inputSchema: {
        type: 'object',
        properties: {},
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === 'run_command') {
      const { command } = args;
      const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${command}`);
      return {
        content: [
          {
            type: 'text',
            text: stdout || stderr || 'Command executed successfully',
          },
        ],
      };
    }
    
    if (name === 'rails_command') {
      const { command } = args;
      const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && rails ${command}`);
      return {
        content: [
          {
            type: 'text',
            text: stdout || stderr || 'Rails command executed successfully',
          },
        ],
      };
    }
    
    if (name === 'project_status') {
      const { stdout } = await execAsync(`cd ${PROJECT_ROOT} && git status --short && echo "---" && rails stats | head -20`);
      return {
        content: [
          {
            type: 'text',
            text: `Project Status:\n${stdout}`,
          },
        ],
      };
    }

    throw new Error(`Unknown tool: ${name}`);
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error.message}`,
        },
      ],
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('kicda-bridge MCP server is running');
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
