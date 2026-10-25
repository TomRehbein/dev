import type { Plugin } from "@opencode/plugin/tui"

const instructions = (focus: string) => `You are writing a handoff prompt that a fresh AI session will receive as its first message.

A fresh session wastes time re-exploring the codebase. Frontload everything it needs so it can start working immediately.

Include:
- The goal and current state of the work
- Decisions, constraints, user preferences and technical patterns that were established
- Relevant files as @path references (files to edit, dependencies, tests, configs, key docs), 8-15 files, up to 20 for complex work
- Concrete next steps

Exclude conversation back-and-forth, dead ends and meta-commentary. Do not duplicate content already captured in specs, plans, issues or commits, reference them by path or URL instead. Redact secrets such as API keys and passwords.

Next session focus: ${focus || "a natural continuation of the current conversation"}

Reply with the handoff prompt only, no preamble.`

const plugin: Plugin.Definition = {
  id: "tom.handoff",
  setup(context) {
    const handoff = async (focus = "") => {
      const route = context.ui.router.current()
      if (route.type !== "session") {
        context.ui.toast.show({ message: "Open a session first", variant: "error" })
        return
      }
      const { sessionID } = route
      try {
        context.ui.toast.show({ message: "Writing handoff prompt...", variant: "info" })
        const source = await context.client.session.get({ sessionID })
        const { text } = await context.client.session.generate({ sessionID, prompt: instructions(focus.trim()) })
        const created = await context.client.session.create({
          title: `Handoff: ${source.title ?? sessionID}`,
          agent: source.agent,
          model: source.model,
          location: context.location,
        })
        context.ui.router.navigate({ type: "session", sessionID: created.id })
        await context.client.session.prompt({
          sessionID: created.id,
          text: `Continuing work from session ${sessionID}.\n\n${text.trim()}`,
        })
      } catch (error) {
        context.ui.toast.show({ title: "Handoff failed", message: String(error), variant: "error" })
      }
    }

    // keymap.layer needs the Keymap provider, which only exists inside a rendered component.
    context.ui.slot({
      append: "app",
      render: () => {
        context.keymap.layer(() => ({
          mode: "global",
          commands: [
            {
              id: "handoff.create",
              title: "Handoff to new session",
              description: "Write a handoff prompt and continue in a new session",
              group: "Session",
              palette: true,
              slash: { name: "handoff", arguments: true },
              run: (input) => handoff(input),
            },
          ],
        }))
        return null
      },
    })
  },
}

export default plugin
