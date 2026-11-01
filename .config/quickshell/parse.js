.pragma library

// Splits a line of `nmcli -t` output: fields are separated by ":", and a
// ":" or "\" inside a field (an SSID, for example) is escaped with "\"
function nmcliFields(line) {
    const fields = [""];
    for (let i = 0; i < line.length; i++) {
        const c = line[i];
        if (c === "\\" && i + 1 < line.length) {
            fields[fields.length - 1] += line[++i];
        } else if (c === ":") {
            fields.push("");
        } else {
            fields[fields.length - 1] += c;
        }
    }
    return fields;
}

// Output of:
//   nmcli -t -f TYPE,STATE,DEVICE device; echo --;
//   nmcli -t -f ACTIVE,SIGNAL,SSID device wifi list --rescan no
// Returns { kind: "wifi" | "ethernet" | "linked" | "disconnected", ... }
function network(text) {
    const [devices, wifi = ""] = text.split("\n--\n");
    let linked = null;

    for (const line of devices.split("\n")) {
        const [type, state, device] = nmcliFields(line);
        if (type !== "wifi" && type !== "ethernet")
            continue;
        if (state === "connected") {
            if (type === "wifi") {
                for (const row of wifi.split("\n")) {
                    const [active, signal, ssid] = nmcliFields(row);
                    if (active === "yes")
                        return { kind: "wifi", device, ssid, signal: parseInt(signal) || 0 };
                }
                return { kind: "wifi", device, ssid: "", signal: 0 };
            }
            return { kind: "ethernet", device };
        }
        // Connected to the network but still without an IP address
        if (state.startsWith("connecting") && !linked)
            linked = { kind: "linked", device };
    }
    return linked || { kind: "disconnected" };
}

// Output of: bluetoothctl show; echo --; bluetoothctl devices Connected
// Returns { present, powered, alias, address, devices: [{ name, address }] }
function bluetooth(text) {
    const [show, connected = ""] = text.split("\n--\n");
    const controller = show.match(/^Controller ([0-9A-F:]{17})/m);
    if (!controller)
        return { present: false, powered: false, alias: "", address: "", devices: [] };

    const alias = (show.match(/^\s*Alias: (.*)$/m) || [])[1] || "";
    const powered = /^\s*Powered: yes$/m.test(show);
    const devices = [];
    for (const line of connected.split("\n")) {
        const device = line.match(/^Device ([0-9A-F:]{17}) (.*)$/);
        if (device)
            devices.push({ address: device[1], name: device[2] });
    }
    return { present: true, powered, alias, address: controller[1], devices };
}
