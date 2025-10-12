#!/usr/bin/env node

import { StdioServerTransport } from '@modelcontextprotocol/sdk/dist/esm/server/stdio.js';
import { Server } from '@modelcontextprotocol/sdk/dist/esm/server/index.js';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

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
  ],
}));

// Handle tool calls
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === 'run_command') {
      const { command } = args;
      const { stdout, stderr } = await execAsync(`cd /Users/l2dogyu/KICDA/ruby/kicda-jh && ${command}`);
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
      const { stdout, stderr } = await execAsync(`cd /Users/l2dogyu/KICDA/ruby/kicda-jh && rails ${command}`);
      return {
        content: [
          {
            type: 'text',
            text: stdout || stderr || 'Rails command executed successfully',
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
  console.error('kicda-bridge MCP server running');
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
