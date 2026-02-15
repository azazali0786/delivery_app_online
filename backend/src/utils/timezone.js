/**
 * Timezone utility — always returns IST (UTC+5:30) regardless of the server's
 * system timezone.  This ensures morning/evening cutoff logic works identically
 * on local machines (IST) and cloud servers (usually UTC).
 *
 * Cutoff: morning = 00:00-13:59 IST, evening = 14:00-23:59 IST
 */

const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000; // +5:30 in milliseconds

/**
 * Return a Date object shifted so that its UTC accessors (getUTCHours, etc.)
 * reflect the current IST wall-clock time.
 */
function getNowIST() {
    const now = new Date();
    return new Date(now.getTime() + IST_OFFSET_MS);
}

/**
 * Today's date string in YYYY-MM-DD format, in IST.
 */
function getTodayDateIST() {
    const ist = getNowIST();
    const y = ist.getUTCFullYear();
    const m = String(ist.getUTCMonth() + 1).padStart(2, '0');
    const d = String(ist.getUTCDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
}

/**
 * Current IST hour (0-23).
 */
function getHourIST() {
    return getNowIST().getUTCHours();
}

/**
 * True when IST hour >= 14 (i.e. 2:00 PM onwards).
 */
function isEveningIST() {
    return getHourIST() >= 14;
}

/**
 * Full ISO-8601 timestamp string using the IST-shifted Date.
 * Useful as a default entry_date for stock entries.
 */
function getNowISOStringIST() {
    const ist = getNowIST();
    return ist.toISOString();
}

module.exports = {
    getNowIST,
    getTodayDateIST,
    getHourIST,
    isEveningIST,
    getNowISOStringIST,
};
