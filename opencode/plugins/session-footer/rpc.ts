import { Rpc } from "@opencode/plugin/rpc"

const window = {
  type: "object",
  properties: {
    used: { type: "number" },
    seconds: { type: "number" },
  },
  required: ["used", "seconds"],
  additionalProperties: false,
} as const

export const CodexUsage = Rpc.define({
  id: "evgeny.codex-usage",
  methods: {
    get: {
      input: {
        type: "object",
        additionalProperties: false,
      },
      output: {
        type: "object",
        properties: {
          available: { type: "boolean" },
          plan: { type: "string" },
          primary: window,
          secondary: window,
        },
        required: ["available"],
        additionalProperties: false,
      },
    },
  },
  events: {},
})
