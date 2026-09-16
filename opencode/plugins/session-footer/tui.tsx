import { Plugin } from "@opencode/plugin/tui"
import { createSignal } from "solid-js"
import { CodexUsage } from "./rpc.js"

const usageColor = (percent: number, theme: Record<string, any>) => {
  if (percent < 50) return theme.success ?? theme.status?.success ?? "#1b7f37"
  if (percent < 80) return theme.warning ?? theme.status?.warning ?? "#9a6700"
  return theme.error ?? theme.status?.error ?? "#cf222e"
}

export default Plugin.define({
  id: "evgeny.session-footer",
  setup(context) {
    const client = context.client.rpc(CodexUsage)
    const [usage, setUsage] = createSignal<{
      available: boolean
      primary?: { used: number; seconds: number; resetsAt: number }
      secondary?: { used: number; seconds: number; resetsAt: number }
    }>({ available: false })
    const refreshUsage = () => void client.get({}).then(setUsage).catch(() => setUsage({ available: false }))
    refreshUsage()
    const timer = setInterval(refreshUsage, 60_000)

    const dispose = context.ui.slot({
      append: "prompt.footer.status",
      render: ({ sessionID }) => {
        const session = context.data.session.get(sessionID)
        const modelRef = session?.model
        const limits = usage()
        if (modelRef?.providerID !== "openai" || !limits.available) return null

        return (
          <box flexDirection="row" gap={1} flexShrink={1}>
            {limits.primary ? (
              <text fg={usageColor(limits.primary.used, context.theme)}>
                {Math.round(limits.primary.seconds / 3600)}h:{Math.round(limits.primary.used)}%
              </text>
            ) : null}
            {limits.secondary ? (
              <text fg={usageColor(limits.secondary.used, context.theme)}>
                {Math.round(limits.secondary.seconds / 86400)}d:{Math.round(limits.secondary.used)}%
              </text>
            ) : null}
          </box>
        )
      },
    })
    return () => {
      clearInterval(timer)
      dispose()
    }
  },
})
