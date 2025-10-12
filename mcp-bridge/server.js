#!/usr/bin/env node

/**
 * Claude Desktop Bridge Server
 * Claude Desktop과 외부 시스템을 연결하는 MCP 브릿지
 */

import { Server } from '@modelcontextprotocol/sdk/dist/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/dist/server/stdio.js';
import { exec } from 'child_process';
import { promisify } from 'util';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.join(__dirname, '..');

// MCP 서버 생성
const server = new Server(
  {
    name: 'claude-desktop-bridge',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Rails 명령 실행 도구
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'rails_command',
      description: 'Rails 명령어 실행',
      inputSchema: {
        type: 'object',
        properties: {
          command: {
            type: 'string',
            description: 'Rails 명령어 (예: generate, db:migrate, test)',
          },
          args: {
            type: 'string',
            description: '명령어 인자',
          },
        },
        required: ['command'],
      },
    },
    {
      name: 'ruby_script',
      description: 'Ruby 스크립트 실행',
      inputSchema: {
        type: 'object',
        properties: {
          script: {
            type: 'string',
            description: 'Ruby 코드',
          },
        },
        required: ['script'],
      },
    },
    {
      name: 'project_status',
      description: '프로젝트 상태 확인',
      inputSchema: {
        type: 'object',
        properties: {},
      },
    },
    {
      name: 'run_tests',
      description: '테스트 실행',
      inputSchema: {
        type: 'object',
        properties: {
          test_file: {
            type: 'string',
            description: '특정 테스트 파일 (선택사항)',
          },
        },
      },
    },
    {
      name: 'generate_code',
      description: '코드 생성 (모델, 컨트롤러, 뷰 등)',
      inputSchema: {
        type: 'object',
        properties: {
          type: {
            type: 'string',
            enum: ['model', 'controller', 'scaffold', 'migration', 'job'],
            description: '생성할 코드 타입',
          },
          name: {
            type: 'string',
            description: '생성할 리소스 이름',
          },
          attributes: {
            type: 'string',
            description: '속성 (예: name:string age:integer)',
          },
        },
        required: ['type', 'name'],
      },
    },
    {
      name: 'database_query',
      description: '데이터베이스 쿼리 실행',
      inputSchema: {
        type: 'object',
        properties: {
          query: {
            type: 'string',
            description: 'SQL 쿼리 또는 Rails 콘솔 명령',
          },
        },
        required: ['query'],
      },
    },
    {
      name: 'ai_assistant',
      description: 'AI 개발 어시스턴트 실행',
      inputSchema: {
        type: 'object',
        properties: {
          intent: {
            type: 'string',
            description: '개발 의도 (예: "로그인 기능 추가해줘")',
          },
        },
        required: ['intent'],
      },
    },
  ],
}));

// 도구 실행 핸들러
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'rails_command': {
        const { command, args: cmdArgs } = args;
        const fullCommand = `cd ${PROJECT_ROOT} && rails ${command} ${cmdArgs || ''}`;
        const { stdout, stderr } = await execAsync(fullCommand);
        return {
          content: [
            {
              type: 'text',
              text: `Rails 명령 실행 완료:\n${stdout}\n${stderr}`,
            },
          ],
        };
      }

      case 'ruby_script': {
        const { script } = args;
        const scriptFile = path.join(PROJECT_ROOT, 'tmp', `script_${Date.now()}.rb`);
        await fs.writeFile(scriptFile, script);
        const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ruby ${scriptFile}`);
        await fs.unlink(scriptFile);
        return {
          content: [
            {
              type: 'text',
              text: `Ruby 스크립트 실행 결과:\n${stdout}\n${stderr}`,
            },
          ],
        };
      }

      case 'project_status': {
        const commands = [
          'git status --short',
          'rails stats',
          'bundle check',
        ];
        
        const results = await Promise.all(
          commands.map(cmd => 
            execAsync(`cd ${PROJECT_ROOT} && ${cmd}`)
              .then(({ stdout }) => stdout)
              .catch(err => `Error: ${err.message}`)
          )
        );

        return {
          content: [
            {
              type: 'text',
              text: `프로젝트 상태:\n\nGit Status:\n${results[0]}\n\nRails Stats:\n${results[1]}\n\nBundle Status:\n${results[2]}`,
            },
          ],
        };
      }

      case 'run_tests': {
        const { test_file } = args;
        const testCommand = test_file 
          ? `rails test ${test_file}`
          : 'rails test';
        
        const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${testCommand}`);
        return {
          content: [
            {
              type: 'text',
              text: `테스트 결과:\n${stdout}\n${stderr}`,
            },
          ],
        };
      }

      case 'generate_code': {
        const { type, name, attributes } = args;
        const generateCommand = `rails generate ${type} ${name} ${attributes || ''}`;
        
        const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${generateCommand}`);
        
        // 마이그레이션이 생성된 경우 자동 실행
        if (type === 'model' || type === 'scaffold') {
          await execAsync(`cd ${PROJECT_ROOT} && rails db:migrate`);
        }
        
        return {
          content: [
            {
              type: 'text',
              text: `코드 생성 완료:\n${stdout}\n${stderr}\n\n데이터베이스 마이그레이션도 실행되었습니다.`,
            },
          ],
        };
      }

      case 'database_query': {
        const { query } = args;
        const dbCommand = `rails runner "puts ${query}"`;
        
        const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${dbCommand}`);
        return {
          content: [
            {
              type: 'text',
              text: `쿼리 결과:\n${stdout}\n${stderr}`,
            },
          ],
        };
      }

      case 'ai_assistant': {
        const { intent } = args;
        const assistantScript = `
          require Rails.root.join('lib', 'ai_development_assistant')
          assistant = AIDevelopmentAssistant.new
          result = assistant.execute_intent("${intent}")
          puts result.to_json
        `;
        
        const scriptFile = path.join(PROJECT_ROOT, 'tmp', `ai_assistant_${Date.now()}.rb`);
        await fs.writeFile(scriptFile, assistantScript);
        
        const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && rails runner ${scriptFile}`);
        await fs.unlink(scriptFile);
        
        return {
          content: [
            {
              type: 'text',
              text: `AI 어시스턴트 실행 결과:\n${stdout}\n${stderr}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `오류 발생: ${error.message}`,
        },
      ],
    };
  }
});

// 리소스 제공
server.setRequestHandler('resources/list', async () => ({
  resources: [
    {
      uri: 'project://status',
      name: 'Project Status',
      description: 'Current project status',
      mimeType: 'text/plain',
    },
    {
      uri: 'project://routes',
      name: 'Rails Routes',
      description: 'Application routes',
      mimeType: 'text/plain',
    },
  ],
}));

server.setRequestHandler('resources/read', async (request) => {
  const { uri } = request.params;

  switch (uri) {
    case 'project://status': {
      const { stdout } = await execAsync(`cd ${PROJECT_ROOT} && rails stats`);
      return {
        contents: [
          {
            uri,
            mimeType: 'text/plain',
            text: stdout,
          },
        ],
      };
    }

    case 'project://routes': {
      const { stdout } = await execAsync(`cd ${PROJECT_ROOT} && rails routes`);
      return {
        contents: [
          {
            uri,
            mimeType: 'text/plain',
            text: stdout,
          },
        ],
      };
    }

    default:
      throw new Error(`Unknown resource: ${uri}`);
  }
});

// 서버 시작
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Claude Desktop Bridge MCP server started');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
