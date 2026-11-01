pragma Singleton

import Quickshell
import QtQuick

// Shell texts in the 10 languages. The language is chosen from the system's:
// exact language, then the same language from another region, then en_US.
// The clock shows the time over the date, in the date order of each language
Singleton {
    readonly property var languages: ({
        "en_US": {
            "search": "Search",
            "shutdown": "Shut down",
            "reboot": "Reboot",
            "lock": "Lock",
            "logout": "Log out",
            "cityPrompt": "City",
            "automatic": "Automatic (from IP)",
            "clock": "HH:mm\nMM/dd/yyyy",
            "clockAlt": "HH:mm\nddd, MM/dd/yyyy",
            "noIp": "No IP",
            "muted": "Muted",
            "volumeHint": "Scroll: adjust volume\nClick: mute/unmute",
            "brightnessHint": "Monitor brightness\nScroll: adjust\nLeft click: 100%\nRight click: 0%"
        },
        "zh_CN": {
            "search": "搜索",
            "shutdown": "关机",
            "reboot": "重启",
            "lock": "锁定",
            "logout": "注销",
            "cityPrompt": "城市",
            "automatic": "自动（根据 IP）",
            "clock": "HH:mm\nyyyy/MM/dd",
            "clockAlt": "HH:mm\nyyyy/MM/dd dddd",
            "noIp": "无 IP",
            "muted": "静音",
            "volumeHint": "滚动：调节音量\n点击：静音/取消静音",
            "brightnessHint": "显示器亮度\n滚动：调节\n左键单击：100%\n右键单击：0%"
        },
        "hi_IN": {
            "search": "खोजें",
            "shutdown": "बंद करें",
            "reboot": "पुनः आरंभ करें",
            "lock": "लॉक करें",
            "logout": "लॉग आउट करें",
            "cityPrompt": "शहर",
            "automatic": "स्वचालित (IP से)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd, dd/MM/yyyy",
            "noIp": "कोई IP नहीं",
            "muted": "म्यूट",
            "volumeHint": "स्क्रॉल: आवाज़ बदलें\nक्लिक: म्यूट/अनम्यूट",
            "brightnessHint": "मॉनिटर की चमक\nस्क्रॉल: बदलें\nबायाँ क्लिक: 100%\nदायाँ क्लिक: 0%"
        },
        "es_ES": {
            "search": "Buscar",
            "shutdown": "Apagar",
            "reboot": "Reiniciar",
            "lock": "Bloquear",
            "logout": "Cerrar sesión",
            "cityPrompt": "Ciudad",
            "automatic": "Automático (por IP)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd, dd/MM/yyyy",
            "noIp": "sin IP",
            "muted": "Silenciado",
            "volumeHint": "Desplazar: ajustar volumen\nClic: silenciar/activar",
            "brightnessHint": "Brillo del monitor\nDesplazar: ajustar\nClic izquierdo: 100%\nClic derecho: 0%"
        },
        "ar_SA": {
            "search": "بحث",
            "shutdown": "إيقاف التشغيل",
            "reboot": "إعادة التشغيل",
            "lock": "قفل",
            "logout": "تسجيل الخروج",
            "cityPrompt": "المدينة",
            "automatic": "تلقائي (حسب IP)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\ndddd، dd/MM/yyyy",
            "noIp": "لا يوجد IP",
            "muted": "صامت",
            "volumeHint": "التمرير: ضبط مستوى الصوت\nالنقر: كتم/إلغاء الكتم",
            "brightnessHint": "سطوع الشاشة\nالتمرير: ضبط\nالنقر الأيسر: 100%\nالنقر الأيمن: 0%"
        },
        "fr_FR": {
            "search": "Rechercher",
            "shutdown": "Éteindre",
            "reboot": "Redémarrer",
            "lock": "Verrouiller",
            "logout": "Se déconnecter",
            "cityPrompt": "Ville",
            "automatic": "Automatique (par IP)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd dd/MM/yyyy",
            "noIp": "pas d'IP",
            "muted": "Muet",
            "volumeHint": "Défiler : régler le volume\nClic : couper/rétablir le son",
            "brightnessHint": "Luminosité de l'écran\nDéfiler : régler\nClic gauche : 100 %\nClic droit : 0 %"
        },
        "bn_BD": {
            "search": "খুঁজুন",
            "shutdown": "বন্ধ করুন",
            "reboot": "পুনরায় চালু করুন",
            "lock": "লক করুন",
            "logout": "লগ আউট করুন",
            "cityPrompt": "শহর",
            "automatic": "স্বয়ংক্রিয় (IP থেকে)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd, dd/MM/yyyy",
            "noIp": "কোনো IP নেই",
            "muted": "নিঃশব্দ",
            "volumeHint": "স্ক্রল: ভলিউম ঠিক করুন\nক্লিক: নিঃশব্দ/শব্দ চালু",
            "brightnessHint": "মনিটরের উজ্জ্বলতা\nস্ক্রল: ঠিক করুন\nবাম ক্লিক: 100%\nডান ক্লিক: 0%"
        },
        "pt_BR": {
            "search": "Buscar",
            "shutdown": "Desligar",
            "reboot": "Reiniciar",
            "lock": "Bloquear",
            "logout": "Sair",
            "cityPrompt": "Cidade",
            "automatic": "Automático (pelo IP)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd, dd/MM/yyyy",
            "noIp": "sem IP",
            "muted": "Mudo",
            "volumeHint": "Rolar: ajustar volume\nClique: silenciar/reativar",
            "brightnessHint": "Brilho do monitor\nRolar: ajustar\nClique esquerdo: 100%\nClique direito: 0%"
        },
        "ru_RU": {
            "search": "Поиск",
            "shutdown": "Выключить",
            "reboot": "Перезагрузить",
            "lock": "Заблокировать",
            "logout": "Выйти",
            "cityPrompt": "Город",
            "automatic": "Автоматически (по IP)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd, dd/MM/yyyy",
            "noIp": "нет IP",
            "muted": "Без звука",
            "volumeHint": "Прокрутка: громкость\nЩелчок: выкл./вкл. звук",
            "brightnessHint": "Яркость монитора\nПрокрутка: настроить\nЛевый щелчок: 100%\nПравый щелчок: 0%"
        },
        "id_ID": {
            "search": "Cari",
            "shutdown": "Matikan",
            "reboot": "Mulai ulang",
            "lock": "Kunci",
            "logout": "Keluar",
            "cityPrompt": "Kota",
            "automatic": "Otomatis (dari IP)",
            "clock": "HH:mm\ndd/MM/yyyy",
            "clockAlt": "HH:mm\nddd, dd/MM/yyyy",
            "noIp": "tanpa IP",
            "muted": "Senyap",
            "volumeHint": "Gulir: atur volume\nKlik: bisukan/bunyikan",
            "brightnessHint": "Kecerahan monitor\nGulir: atur\nKlik kiri: 100%\nKlik kanan: 0%"
        }
    })

    readonly property var t: pick(Qt.locale().name)

    // A date in a Qt format, in the system language
    function format(date, pattern) {
        return date.toLocaleString(Qt.locale(), pattern);
    }

    function pick(name) {
        if (languages[name])
            return languages[name];
        const language = name.split("_")[0];
        for (const code in languages) {
            if (code.split("_")[0] === language)
                return languages[code];
        }
        return languages["en_US"];
    }
}
