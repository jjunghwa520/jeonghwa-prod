#!/usr/bin/env node

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const fs = require("fs").promises;
const path = require("path");
const pdfParse = require("pdf-parse");
const { HWPDocument } = require("node-hwp");

class DocumentReaderServer {
  constructor() {
    this.server = new Server(
      {
        name: "document-reader-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupHandlers();
    this.server.onerror = (error) => console.error("[MCP Error]", error);
    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "read_pdf",
          description: "PDF 파일을 읽어서 텍스트 내용을 추출합니다.",
          inputSchema: {
            type: "object",
            properties: {
              file_path: {
                type: "string",
                description: "읽을 PDF 파일의 절대 경로",
              },
            },
            required: ["file_path"],
          },
        },
        {
          name: "read_hwp",
          description: "HWP(한글) 파일을 읽어서 텍스트 내용을 추출합니다.",
          inputSchema: {
            type: "object",
            properties: {
              file_path: {
                type: "string",
                description: "읽을 HWP 파일의 절대 경로",
              },
            },
            required: ["file_path"],
          },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        if (name === "read_pdf") {
          return await this.readPdf(args.file_path);
        } else if (name === "read_hwp") {
          return await this.readHwp(args.file_path);
        } else {
          throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: "text",
              text: `Error: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  async readPdf(filePath) {
    try {
      const dataBuffer = await fs.readFile(filePath);
      const data = await pdfParse(dataBuffer);

      const result = {
        title: data.info?.Title || path.basename(filePath),
        author: data.info?.Author || "Unknown",
        pages: data.numpages,
        text: data.text,
      };

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(result, null, 2),
          },
        ],
      };
    } catch (error) {
      throw new Error(`Failed to read PDF: ${error.message}`);
    }
  }

  async readHwp(filePath) {
    try {
      const buffer = await fs.readFile(filePath);
      const hwpDoc = new HWPDocument(buffer);
      
      // HWP 문서 파싱
      const sections = hwpDoc.getSections();
      let text = "";
      
      sections.forEach((section, idx) => {
        text += `\n=== Section ${idx + 1} ===\n`;
        text += section.getText();
      });

      const result = {
        filename: path.basename(filePath),
        sections: sections.length,
        text: text.trim(),
      };

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(result, null, 2),
          },
        ],
      };
    } catch (error) {
      throw new Error(`Failed to read HWP: ${error.message}`);
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Document Reader MCP Server running on stdio");
  }
}

const server = new DocumentReaderServer();
server.run().catch(console.error);

