import { Plugin } from "@opencode/plugin"
import { CodexUsage } from "./rpc.js"

type Credential = {
  type: string
  access?: string
  metadata?: { accountID?: string }
}

type UsageWindow = {
  used_percent?: number
  limit_window_seconds?: number
  reset_at?: number
}

type UsagePayload = {
  plan_type?: string
  rate_limit?: {
    primary_window?: UsageWindow | null
    secondary_window?: UsageWindow | null
  } | null
}

type Usage = {
  available: boolean
  plan?: string
  primary?: { used: number; seconds: number; resetsAt: number }
  secondary?: { used: number; seconds: number; resetsAt: number }
}

const mapWindow = (window: UsageWindow | null | undefined) => {
  if (
    window?.used_percent === undefined ||
    window.limit_window_seconds === undefined ||
    window.reset_at === undefined
  )
    return undefined
  return {
    used: window.used_percent,
    seconds: window.limit_window_seconds,
    resetsAt: window.reset_at,
  }
}

export default Plugin.define({
  id: "evgeny.session-footer.server",
  async setup(context) {
    let cached: { at: number; usage: Usage } | undefined

    const getUsage = async (): Promise<Usage> => {
      if (cached && Date.now() - cached.at < 60_000) return cached.usage

      const connection = await context.integration.connection.active("openai")
      const credential = connection
        ? ((await context.integration.connection.resolve(connection)) as Credential | undefined)
        : undefined
      if (credential?.type !== "oauth" || !credential.access) return { available: false }

      const headers = new Headers({ Authorization: `Bearer ${credential.access}` })
      const accountID = credential.metadata?.accountID
      if (accountID) headers.set("ChatGPT-Account-Id", accountID)

      try {
        const response = await fetch("https://chatgpt.com/backend-api/wham/usage", { headers })
        if (!response.ok) return { available: false }
        const payload = (await response.json()) as UsagePayload
        const usage: Usage = {
          available: true,
          plan: payload.plan_type,
          primary: mapWindow(payload.rate_limit?.primary_window),
          secondary: mapWindow(payload.rate_limit?.secondary_window),
        }
        cached = { at: Date.now(), usage }
        return usage
      } catch {
        return { available: false }
      }
    }

    await context.rpc.register(CodexUsage, { get: getUsage })
  },
})
