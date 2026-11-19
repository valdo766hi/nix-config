import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, props, window, shared, setShared, updates, layout, exec, checking } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// To the rail (on macOS wide enough for the traffic lights), or back to the width it had.
function toggleSidebar() {
  const width = find(layout(), "sidebar")?.size?.px;
  if (!narrow()) setShared("sidebar.width", width);
  // Mods edited before the rail went by width still read the flag.
  setShared("sidebar.collapsed", !narrow());
  run("layout.resize", { id: "sidebar", px: narrow() ? (shared("sidebar.width") ?? 268) : window()?.platform === "macos" ? 76 : 44 });
}

export default class WorkspaceChrome extends View {
  init(_props, cx) {
    this.host = "This computer";
    if (checking() || !props()?.footer) return;
    cx.spawn(async (cx) => {
      try { const r = await exec("hostname", ["-s"]); if (r.code === 0 && r.stdout.trim()) this.host = r.stdout.trim(); } catch {}
      cx.notify();
    });
  }
  button(id, label, action) {
    const t = theme();
    return div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.muted).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_click(action).child(label);
  }
  render() {
    const t = theme();
    const collapsed = narrow();
    if (props()?.footer) {
      const ready = div().size(6).rounded_full().bg(t.accent);
      const settings = this.button("settings", svg("mods/dusk-chrome/settings.svg").size(14), () => run("app.settings")).relative().tooltip("Settings")
        .when(Boolean(updates().app.ready), el => el.child(ready.absolute().top(4).right(4)));
      const machine = this.button("machine", svg("mods/dusk-chrome/plus.svg").size(14), () => run("mod.open", { name: "machine-add" })).tooltip("Add machine");
      if (collapsed) return v_flex().size_full().bg(t.chrome).items_center().justify_center().gap(4).child(settings).child(machine);
      return h_flex().size_full().bg(t.chrome).pl(22).pr(12).gap(2).items_center().text_size(13).text_color(t.dim)
        .child(h_flex().flex_1().min_w(0).gap(4).child(div().min_w(0).truncate().child(this.host)).child(div().flex_none().child("\u00b7 connected")))
        .child(settings).child(machine);
    }
    return h_flex().size_full().bg(t.chrome).pl(collapsed ? 6 : 14).pr(10).gap(4).items_center().text_size(13.5)
      .when(window()?.platform === "macos" && !window()?.fullscreen && !collapsed, el => el.pl(76))
      .when(!collapsed, el => el.child(h_flex().flex_1().gap(9).items_center().child(svg("mods/dusk-chrome/logo.svg").size(14).text_color(t.accent)).child(div().text_size(15).font_semibold().text_color(t.foreground).child("herdr"))))
      .when(!collapsed, el => el.child(this.button("search", svg("mods/dusk-chrome/search.svg").size(15), () => run("mod.open", { name: "picker" }))))
      // On the macOS rail the traffic lights fill the row; the agents list's » unfolds it.
      .when(!(collapsed && window()?.platform === "macos"), el => el.child(this.button("sidebar-toggle", svg("mods/dusk-chrome/sidebar.svg").size(15), toggleSidebar)));
  }
}
