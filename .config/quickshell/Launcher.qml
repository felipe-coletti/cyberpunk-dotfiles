import Quickshell
import QtQuick

// App launcher (SUPER + D). Typing filters the apps by name first, then by
// description and keywords
Menu {
    name: "launcher"
    placeholder: I18n.t.search

    entries: {
        const q = query.trim().toLowerCase();
        const rank = app => {
            const name = app.name.toLowerCase();
            if (q === "" || name.startsWith(q))
                return 0;
            if (name.includes(q))
                return 1;
            const other = [app.genericName, app.comment, ...app.keywords].join(" ").toLowerCase();
            return other.includes(q) ? 2 : -1;
        };

        return DesktopEntries.applications.values
            .filter(app => !app.noDisplay)
            .map(app => ({ app, rank: rank(app) }))
            .filter(item => item.rank >= 0)
            .sort((a, b) => a.rank - b.rank || a.app.name.localeCompare(b.app.name))
            .map(({ app }) => ({
                label: app.name,
                image: Quickshell.iconPath(app.icon, "application-x-executable"),
                run: () => app.execute()
            }));
    }
}
