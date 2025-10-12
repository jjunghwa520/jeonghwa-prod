#!/usr/bin/env node

const { Server } = require('@modelcontextprotocol/sdk/dist/cjs/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/dist/cjs/server/stdio.js');
const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');
const chokidar = require('chokidar');

const execAsync = promisify(exec);
const PROJECT_ROOT = process.env.CURSOR_WORKSPACE || '/Users/l2dogyu/KICDA/ruby/kicda-jh';
const BRIDGE_DIR = process.env.AI_BRIDGE_DIR || path.join(PROJECT_ROOT, '.ai-bridge');

class CursorClaudeBridge {
  constructor() {
    this.server = new Server(
      {
        name: 'cursor-claude-bridge',
        version: '1.0.0',
        description: 'Bidirectional bridge between Cursor AI and Claude'
      },
      {
        capabilities: {
          tools: {},
          resources: {}
        }
      }
    );
    
    this.setupHandlers();
    this.setupWatcher();
  }

  setupHandlers() {
    // 도구 목록
    this.server.setRequestHandler('tools/list', async () => ({
      tools: [
        {
          name: 'cursor_request',
          description: 'Cursor AI에게 작업 요청',
          inputSchema: {
            type: 'object',
            properties: {
              task: { type: 'string', description: '요청할 작업' },
              context: { type: 'object', description: '추가 컨텍스트' }
            },
            required: ['task']
          }
        },
        {
          name: 'claude_execute',
          description: 'Claude가 작업 실행',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: { type: 'string', description: '작업 ID' }
            },
            required: ['task_id']
          }
        },
        {
          name: 'cursor_review',
          description: 'Cursor가 결과 검토',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: { type: 'string', description: '작업 ID' },
              approve: { type: 'boolean', description: '승인 여부' },
              feedback: { type: 'string', description: '피드백' }
            },
            required: ['task_id']
          }
        },
        {
          name: 'get_task_status',
          description: '작업 상태 확인',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: { type: 'string', description: '작업 ID' }
            },
            required: ['task_id']
          }
        },
        {
          name: 'tail_logs',
          description: '브릿지 로그 마지막 N라인 확인',
          inputSchema: {
            type: 'object',
            properties: {
              lines: { type: 'number', description: '라인 수', default: 100 }
            }
          }
        },
        {
          name: 'approve_task',
          description: '검토 승인 후 작업을 최종 완료 처리',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: { type: 'string' }
            },
            required: ['task_id']
          }
        }
        {
          name: 'auto_develop',
          description: '완전 자동 개발 모드',
          inputSchema: {
            type: 'object',
            properties: {
              intent: { type: 'string', description: '개발 의도' },
              max_iterations: { type: 'number', description: '최대 반복 횟수' }
            },
            required: ['intent']
          }
        }
      ]
    }));

    // 도구 실행
    this.server.setRequestHandler('tools/call', async (request) => {
      const { name, arguments: args } = request.params;
      
      try {
        switch(name) {
          case 'cursor_request':
            return await this.cursorRequest(args);
          case 'claude_execute':
            return await this.claudeExecute(args);
          case 'cursor_review':
            return await this.cursorReview(args);
          case 'get_task_status':
            return await this.getTaskStatus(args);
          case 'tail_logs':
            return await this.tailLogs(args);
          case 'approve_task':
            return await this.approveTask(args);
          case 'auto_develop':
            return await this.autoDevelop(args);
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

    // 리소스
    this.server.setRequestHandler('resources/list', async () => ({
      resources: [
        {
          uri: 'bridge://tasks',
          name: 'Active Tasks',
          mimeType: 'application/json'
        },
        {
          uri: 'bridge://results',
          name: 'Task Results',
          mimeType: 'application/json'
        },
        {
          uri: 'bridge://logs',
          name: 'Bridge Logs',
          mimeType: 'text/plain'
        }
      ]
    }));

    this.server.setRequestHandler('resources/read', async (request) => {
      const { uri } = request.params;
      
      switch(uri) {
        case 'bridge://tasks':
          return await this.getActiveTasks();
        case 'bridge://results':
          return await this.getTaskResults();
        case 'bridge://logs':
          return await this.getBridgeLogs();
        default:
          throw new Error(`Unknown resource: ${uri}`);
      }
    });
  }

  setupWatcher() {
    // 작업 디렉토리 감시
    const taskDir = path.join(BRIDGE_DIR, 'tasks');
    const resultDir = path.join(BRIDGE_DIR, 'results');
    
    // 디렉토리 생성
    this.ensureDirectories();
    
    // 파일 감시
    this.watcher = chokidar.watch([taskDir, resultDir], {
      persistent: true,
      ignoreInitial: true
    });
    
    this.watcher.on('add', async (filePath) => {
      console.error(`New file detected: ${filePath}`);
      
      if (filePath.includes('/tasks/')) {
        // 새 작업 감지 - Claude가 실행
        const taskId = path.basename(filePath, '.json');
        await this.processNewTask(taskId);
      } else if (filePath.includes('/results/')) {
        // 결과 감지 - Cursor가 검토
        const taskId = path.basename(filePath, '.json');
        await this.processNewResult(taskId);
      }
    });
  }

  async ensureDirectories() {
    const dirs = [
      BRIDGE_DIR,
      path.join(BRIDGE_DIR, 'tasks'),
      path.join(BRIDGE_DIR, 'results'),
      path.join(BRIDGE_DIR, 'reviews'),
      path.join(BRIDGE_DIR, 'logs')
    ];
    
    for (const dir of dirs) {
      await fs.mkdir(dir, { recursive: true });
    }
  }

  async cursorRequest(args) {
    const { task, context } = args;
    const taskId = `task_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    
    const taskData = {
      id: taskId,
      source: 'cursor',
      task: task,
      context: context || {},
      status: 'pending',
      created_at: new Date().toISOString(),
      iteration: 0
    };
    
    // 작업 파일 생성
    await fs.writeFile(
      path.join(BRIDGE_DIR, 'tasks', `${taskId}.json`),
      JSON.stringify(taskData, null, 2)
    );
    
    return {
      content: [{
        type: 'text',
        text: `Task created: ${taskId}\nTask: ${task}\nStatus: Pending execution by Claude`
      }]
    };
  }

  async claudeExecute(args) {
    const { task_id } = args;
    const taskFile = path.join(BRIDGE_DIR, 'tasks', `${task_id}.json`);
    
    try {
      const taskData = JSON.parse(await fs.readFile(taskFile, 'utf-8'));
      
      // 작업 실행
      const result = await this.executeTask(taskData);
      
      // 결과 저장
      const resultData = {
        task_id: task_id,
        result: result,
        status: result.success ? 'completed' : 'failed',
        needs_review: true,
        executed_at: new Date().toISOString()
      };
      
      await fs.writeFile(
        path.join(BRIDGE_DIR, 'results', `${task_id}.json`),
        JSON.stringify(resultData, null, 2)
      );
      
      return {
        content: [{
          type: 'text',
          text: `Task executed: ${task_id}\nSuccess: ${result.success}\nOutput: ${result.output}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `Failed to execute task ${task_id}: ${error.message}`
        }]
      };
    }
  }

  async cursorReview(args) {
    const { task_id, approve, feedback } = args;
    const resultFile = path.join(BRIDGE_DIR, 'results', `${task_id}.json`);
    
    try {
      const resultData = JSON.parse(await fs.readFile(resultFile, 'utf-8'));
      
      const reviewData = {
        task_id: task_id,
        approved: approve,
        feedback: feedback,
        reviewed_at: new Date().toISOString()
      };
      
      await fs.writeFile(
        path.join(BRIDGE_DIR, 'reviews', `${task_id}.json`),
        JSON.stringify(reviewData, null, 2)
      );
      
      if (!approve && feedback) {
        // 재작업 필요
        await this.createRevisionTask(task_id, feedback);
      }
      
      return {
        content: [{
          type: 'text',
          text: `Review completed: ${task_id}\nApproved: ${approve}\nFeedback: ${feedback || 'None'}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `Failed to review task ${task_id}: ${error.message}`
        }]
      };
    }
  }

  async getTaskStatus(args) {
    const { task_id } = args;
    
    try {
      const taskFile = path.join(BRIDGE_DIR, 'tasks', `${task_id}.json`);
      const resultFile = path.join(BRIDGE_DIR, 'results', `${task_id}.json`);
      const reviewFile = path.join(BRIDGE_DIR, 'reviews', `${task_id}.json`);
      
      let status = { task_id: task_id };
      
      if (await this.fileExists(taskFile)) {
        status.task = JSON.parse(await fs.readFile(taskFile, 'utf-8'));
      }
      
      if (await this.fileExists(resultFile)) {
        status.result = JSON.parse(await fs.readFile(resultFile, 'utf-8'));
      }
      
      if (await this.fileExists(reviewFile)) {
        status.review = JSON.parse(await fs.readFile(reviewFile, 'utf-8'));
      }
      
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(status, null, 2)
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `Failed to get status for task ${task_id}: ${error.message}`
        }]
      };
    }
  }

  async tailLogs(args) {
    const { lines = 100 } = args || {};
    const logFile = path.join(BRIDGE_DIR, 'logs', 'bridge.log');
    try {
      const logs = await fs.readFile(logFile, 'utf-8');
      const tail = logs.split('\n').slice(-Math.max(1, lines)).join('\n');
      return {
        content: [{ type: 'text', text: tail || 'No logs' }]
      };
    } catch (error) {
      return {
        content: [{ type: 'text', text: `No logs available: ${error.message}` }]
      };
    }
  }

  async approveTask(args) {
    const { task_id } = args;
    const script = `
      require '${PROJECT_ROOT}/ai-bridge/bidirectional_bridge'
      bridge = BidirectionalAIBridge.new
      result = bridge.approve_task('${task_id}')
      puts result.to_json
    `;
    try {
      const { stdout } = await execAsync(`cd ${PROJECT_ROOT} && rails runner "${script}" 2>&1`);
      return { content: [{ type: 'text', text: stdout.trim() }] };
    } catch (error) {
      return { content: [{ type: 'text', text: `approve failed: ${error.message}` }] };
    }
  }

  async autoDevelop(args) {
    const { intent, max_iterations = 5 } = args;
    let iteration = 0;
    let taskId = null;
    let approved = false;
    
    // 초기 작업 생성
    const initialTask = await this.cursorRequest({ task: intent });
    taskId = initialTask.content[0].text.match(/Task created: (\w+)/)[1];
    
    while (iteration < max_iterations && !approved) {
      iteration++;
      
      // Claude 실행
      await this.claudeExecute({ task_id: taskId });
      
      // 자동 검토 (테스트 실행)
      const testResult = await execAsync(`cd ${PROJECT_ROOT} && rails test 2>&1`);
      const hasErrors = testResult.stdout.includes('Error') || testResult.stderr;
      
      if (!hasErrors) {
        approved = true;
        await this.cursorReview({
          task_id: taskId,
          approve: true,
          feedback: 'All tests passed'
        });
      } else {
        await this.cursorReview({
          task_id: taskId,
          approve: false,
          feedback: `Tests failed: ${testResult.stdout.substring(0, 200)}`
        });
        
        // 수정 작업 생성
        taskId = await this.createRevisionTask(taskId, 'Fix test failures');
      }
    }
    
    return {
      content: [{
        type: 'text',
        text: `Auto-development completed\nIntent: ${intent}\nIterations: ${iteration}\nApproved: ${approved}`
      }]
    };
  }

  async executeTask(taskData) {
    const { task } = taskData;
    
    try {
      // Ruby 브릿지 스크립트 실행
      const script = `
        require '${PROJECT_ROOT}/ai-bridge/bidirectional_bridge'
        bridge = BidirectionalAIBridge.new
        task = bridge.cursor_creates_task("${task}")
        bridge.claude_executes_task(task[:id])
      `;
      
      const { stdout, stderr } = await execAsync(
        `cd ${PROJECT_ROOT} && rails runner "${script}" 2>&1`
      );
      
      return {
        success: !stderr || stderr.length === 0,
        output: stdout || stderr
      };
    } catch (error) {
      return {
        success: false,
        output: error.message
      };
    }
  }

  async createRevisionTask(originalTaskId, feedback) {
    const revisionId = `${originalTaskId}_rev_${Date.now()}`;
    
    const revisionTask = {
      id: revisionId,
      original_task: originalTaskId,
      task: `Fix issues: ${feedback}`,
      status: 'pending',
      created_at: new Date().toISOString()
    };
    
    await fs.writeFile(
      path.join(BRIDGE_DIR, 'tasks', `${revisionId}.json`),
      JSON.stringify(revisionTask, null, 2)
    );
    
    return revisionId;
  }

  async processNewTask(taskId) {
    console.error(`Processing new task: ${taskId}`);
    // Claude가 자동으로 실행
    await this.claudeExecute({ task_id: taskId });
  }

  async processNewResult(taskId) {
    console.error(`Processing new result: ${taskId}`);
    // Cursor가 자동으로 검토 (여기서는 시뮬레이션)
    const resultFile = path.join(BRIDGE_DIR, 'results', `${taskId}.json`);
    const resultData = JSON.parse(await fs.readFile(resultFile, 'utf-8'));
    
    // 간단한 자동 검토
    const approved = resultData.result && resultData.result.success;
    await this.cursorReview({
      task_id: taskId,
      approve: approved,
      feedback: approved ? 'Looks good' : 'Needs revision'
    });
  }

  async getActiveTasks() {
    const tasksDir = path.join(BRIDGE_DIR, 'tasks');
    const files = await fs.readdir(tasksDir);
    const tasks = [];
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const content = await fs.readFile(path.join(tasksDir, file), 'utf-8');
        tasks.push(JSON.parse(content));
      }
    }
    
    return {
      contents: [{
        uri: 'bridge://tasks',
        mimeType: 'application/json',
        text: JSON.stringify(tasks, null, 2)
      }]
    };
  }

  async getTaskResults() {
    const resultsDir = path.join(BRIDGE_DIR, 'results');
    const files = await fs.readdir(resultsDir);
    const results = [];
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const content = await fs.readFile(path.join(resultsDir, file), 'utf-8');
        results.push(JSON.parse(content));
      }
    }
    
    return {
      contents: [{
        uri: 'bridge://results',
        mimeType: 'application/json',
        text: JSON.stringify(results, null, 2)
      }]
    };
  }

  async getBridgeLogs() {
    const logFile = path.join(BRIDGE_DIR, 'logs', 'bridge.log');
    
    try {
      const logs = await fs.readFile(logFile, 'utf-8');
      return {
        contents: [{
          uri: 'bridge://logs',
          mimeType: 'text/plain',
          text: logs
        }]
      };
    } catch (error) {
      return {
        contents: [{
          uri: 'bridge://logs',
          mimeType: 'text/plain',
          text: 'No logs available'
        }]
      };
    }
  }

  async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Cursor-Claude Bridge MCP Server started');
  }
}

// 서버 시작
const bridge = new CursorClaudeBridge();
bridge.start().catch(console.error);
