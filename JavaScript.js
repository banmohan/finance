function convertDate(d) {
    try {
        const date = new Date(parseInt(d.substr(6)));
        return date;
    } catch (e) {
        return null;
    };
};

function parseLocalizedDate(dateString) {
    if (!dateString) {
        return "";
    };

    const date = Date.parseExact(dateString, window.shortDateFormat);

    if (date) {
        const offset = date.getTimezoneOffset() * 60000;

        return new Date(date.getTime() - offset).toISOString();
    };

    return dateString;
};

function getTime(dateTime) {
    if (!dateTime) {
        return "";
    };

    function padMinutes(minutes) {
        if (parseInt(minutes || 0) < 10) {
            return `0${minutes}`;
        };

        return minutes;
    };

    value = dateTime.getHours() + ":" + padMinutes(dateTime.getMinutes());

    return value;
};

function dateAdd(d, expression, number) {
    var ret = new Date();

    if (expression === "d") {
        ret = new Date(d.getFullYear(), d.getMonth(), d.getDate() + parseInt(number));
    };

    if (expression === "m") {
        ret = new Date(d.getFullYear(), d.getMonth() + parseInt(number), d.getDate());
    };

    if (expression === "y") {
        ret = new Date(d.getFullYear() + parseInt(number), d.getMonth(), d.getDate());
    };

    return ret.toString(window.shortDateFormat);
};

function convertNetDateFormat(format) {
    //Convert the date
    format = format.replace("dddd", "DD");
    format = format.replace("ddd", "D");

    //Convert month
    if (format.indexOf("MMMM") !== -1) {
        format = format.replace("MMMM", "MM");
    }

    if (format.indexOf("MMM") !== -1) {
        format = format.replace("MMM", "M");
    }

    if (format.indexOf("MM") !== -1) {
        format = format.replace("MM", "mm");
    }

    format = format.replace("M", "m");

    //Convert year
    format = format.indexOf("yyyy") >= 0 ? format.replace("yyyy", "yy") : format.replace("yy", "y");

    return format;
}

function loadDatepicker() {
    loadPersister();

    if (!$.isFunction($.fn.datepicker)) {
        return;
    };

    if (typeof (window.datepickerFormat) === "undefined") {
        window.datepickerFormat = "";
    }
    if (typeof (window.datepickerShowWeekNumber) === "undefined") {
        window.datepickerShowWeekNumber = false;
    }
    if (typeof (window.datepickerWeekStartDay) === "undefined") {
        window.datepickerWeekStartDay = "1";
    }
    if (typeof (window.datepickerNumberOfMonths) === "undefined") {
        window.datepickerNumberOfMonths = "";
    }
    if (typeof (window.language) === "undefined") {
        window.language = "";
    }

    const candidates = $("input.date:not([readonly]), input[type=date]:not([readonly])");

    candidates.datepicker(
        {
            dateFormat: datepickerFormat,
            showWeek: datepickerShowWeekNumber,
            firstDay: datepickerWeekStartDay,
            constrainInput: false,
            numberOfMonths: eval(datepickerNumberOfMonths)
        },
        $.datepicker.regional[language]);


    $.each(candidates, function () {
        const el = $(this);

        //Chrome does not support <input type="date" /> and jQuery UI datepicker
        if (el.attr("type") === "date") {
            el.attr("type", "text");
        };

        const val = el.val();
        var expression = el.attr("data-expression");

        if (expression) {
            el.val(expression).trigger("blur");
        };

        if (!val) {
            if (window.today) {
                el.datepicker("setDate", new Date(window.today));
            };
        };
    });

    candidates.blur(function () {
        if (window.today === "") return;
        var date = new Date(window.today);

        if (window.customVars && window.customVars.Today) {
            date = new Date(window.customVars.Today);
        };

        var control = $(this);
        var expression = control.val().trim().toLowerCase();
        var result;
        var number;

        if (expression === "bom") {
            result = window.customVars.MonthStartDate;
        };

        if (expression === "eom") {
            result = window.customVars.MonthEndDate;
        };

        if (expression === "boq") {
            result = window.customVars.QuarterStartDate;
        };


        if (expression === "eoq") {
            result = window.customVars.QuarterEndDate;
        };


        if (expression === "boh") {
            result = window.customVars.FiscalHalfStartDate;
        };


        if (expression === "eoh") {
            result = window.customVars.FiscalHalfEndDate;
        };

        if (expression === "boy") {
            result = window.customVars.FiscalYearStartDate;
        };

        if (expression === "eoy") {
            result = window.customVars.FiscalYearEndDate;
        };


        if (expression === "d") {
            result = dateAdd(date, "d", 0);
        }; //Today
        if (expression === "w" || expression === "+w") {
            result = dateAdd(date, "d", 7);
        }; //Next Week
        if (expression === "m" || expression === "+m") {
            result = dateAdd(date, "m", 1);
        }; //Next Month
        if (expression === "y" || expression === "+y") {
            result = dateAdd(date, "y", 1);
        }; //Next Year


        if (expression === "-d") {
            result = dateAdd(date, "d", -1);
        }; //YesterDay      
        if (expression === "+d") {
            result = dateAdd(date, "d", 1);
        }; //Tomorrow
        if (expression === "-w") {
            result = dateAdd(date, "d", -7);
        }; //Last Week
        if (expression === "-m") {
            result = dateAdd(date, "m", -1);
        }; //Last Month
        if (expression === "-y") {
            result = dateAdd(date, "y", -1);
        };

        if (!result) {
            if (expression.indexOf("d") >= 0) {
                number = parseInt(expression.replace("d"));
                result = dateAdd(date, "d", number);
            };
            if (expression.indexOf("w") >= 0) {
                number = parseInt(expression.replace("w"));
                result = dateAdd(date, "d", number * 7);
            };
            if (expression.indexOf("m") >= 0) {
                number = parseInt(expression.replace("m"));
                result = dateAdd(date, "m", number);
            };
            if (expression.indexOf("y") >= 0) {
                number = parseInt(expression.replace("y"));
                result = dateAdd(date, "y", number);
            };
        };

        if (result) {
            control.val(result).trigger("change");
        };
    });

    $('[data-type="time"], .time').timepicker({ timeFormat: "H:i" });
    $('[data-type="time"], .time').attr("placeholder", "hh:mm");
    candidates.trigger("blur");
};

$(document).ready(function () {
    loadDatepicker();
});