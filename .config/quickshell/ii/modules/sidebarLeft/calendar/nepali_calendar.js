// Nepali calendar utilities and conversion functions
// Based on Bikram Sambat (BS) calendar system

.pragma library

// Nepali month names
var nepaliMonths = [
    "बैशाख", "जेठ", "आषाढ़", "श्रावण", "भाद्र", "आश्विन",
    "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत्र"
];

var nepaliMonthsEng = [
    "Baisakh", "Jestha", "Ashadh", "Shrawan", "Bhadra", "Ashwin",
    "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra"
];

// Days of week in Nepali
var nepaliWeekDays = [
    {day: "आइत", today: false}, // Sunday
    {day: "सोम", today: false}, // Monday
    {day: "मंगल", today: false}, // Tuesday
    {day: "बुध", today: false}, // Wednesday
    {day: "बिहि", today: false}, // Thursday
    {day: "शुक्र", today: false}, // Friday
    {day: "शनि", today: false}  // Saturday
];

// Reference date: 2000 AD Jan 1 = 2056 BS Poush 17
var referenceAdDate = new Date(2000, 0, 1); // Jan 1, 2000
var referenceBsYear = 2056;
var referenceBsMonth = 9; // Poush (0-indexed)
var referenceBsDay = 17;

// Days in each Nepali month for different years (simplified version)
// In reality, this would need a comprehensive lookup table
var nepaliMonthDays = {
    2080: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30], // 2023-24
    2081: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31], // 2024-25
    2082: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31]  // 2025-26
};

function getDaysInNepaliMonth(year, month) {
    if (nepaliMonthDays[year]) {
        return nepaliMonthDays[year][month];
    }
    // Default fallback - this should be replaced with proper lookup
    var defaultDays = [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
    return defaultDays[month];
}

function getCurrentNepaliDate() {
    // Simplified conversion - in practice you'd use a proper conversion library
    var today = new Date();
    var currentYear = today.getFullYear();
    var currentMonth = today.getMonth();
    
    // Rough approximation: Add 56-57 years to AD to get BS
    var nepaliYear = currentYear + 57;
    var nepaliMonth = currentMonth + 3; // Rough offset
    
    if (nepaliMonth > 11) {
        nepaliMonth -= 12;
        nepaliYear++;
    }
    
    var nepaliDay = today.getDate();
    
    return {
        year: nepaliYear,
        month: nepaliMonth,
        day: nepaliDay
    };
}

function getNepaliCalendarLayout(viewingDate, isCurrentMonth) {
    var nepaliDate = getCurrentNepaliDate();
    var year = nepaliDate.year;
    var month = nepaliDate.month;
    
    var daysInMonth = getDaysInNepaliMonth(year, month);
    var today = new Date();
    var todayDate = today.getDate();
    
    // Create 6 weeks of calendar
    var calendar = [];
    
    for (var week = 0; week < 6; week++) {
        calendar[week] = [];
        for (var day = 0; day < 7; day++) {
            var dayNumber = week * 7 + day - 6; // Adjust for first day of month
            var isToday = 0;
            var dayText = "";
            
            if (dayNumber > 0 && dayNumber <= daysInMonth) {
                dayText = dayNumber.toString();
                if (isCurrentMonth && dayNumber === todayDate) {
                    isToday = 1; // Today
                }
            } else if (dayNumber <= 0) {
                // Previous month days
                var prevMonth = month - 1;
                var prevYear = year;
                if (prevMonth < 0) {
                    prevMonth = 11;
                    prevYear--;
                }
                var prevMonthDays = getDaysInNepaliMonth(prevYear, prevMonth);
                dayText = (prevMonthDays + dayNumber).toString();
                isToday = -1; // Previous month
            } else {
                // Next month days
                dayText = (dayNumber - daysInMonth).toString();
                isToday = -1; // Next month
            }
            
            calendar[week][day] = {
                day: dayText,
                today: isToday
            };
        }
    }
    
    return calendar;
}

function getNepaliDateInXMonthsTime(monthShift) {
    var nepaliDate = getCurrentNepaliDate();
    var newMonth = nepaliDate.month + monthShift;
    var newYear = nepaliDate.year;
    
    while (newMonth > 11) {
        newMonth -= 12;
        newYear++;
    }
    while (newMonth < 0) {
        newMonth += 12;
        newYear--;
    }
    
    return {
        year: newYear,
        month: newMonth,
        day: nepaliDate.day,
        monthName: nepaliMonthsEng[newMonth],
        monthNameNepali: nepaliMonths[newMonth]
    };
}