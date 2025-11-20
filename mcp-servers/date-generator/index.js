#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema, } from '@modelcontextprotocol/sdk/types.js';
// Constants
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
// Core utilities
function getOrdinalSuffix(num) {
    const suffixes = ['th', 'st', 'nd', 'rd'];
    const value = num % 100;
    return num + (suffixes[(value - 20) % 10] || suffixes[value] || suffixes[0]);
}
function getTodayUTC() {
    const now = new Date();
    return new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
}
function getDateInfoRelativeToToday(date) {
    const today = getTodayUTC();
    const targetUTC = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const daysFromToday = Math.floor((targetUTC.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return {
        date: date.toISOString().split('T')[0],
        formatted: date.toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }),
        daysFromToday,
        weeksFromToday: parseFloat((daysFromToday / 7).toFixed(2)),
        isPast: daysFromToday < 0,
        isToday: daysFromToday === 0,
        isFuture: daysFromToday > 0
    };
}
function validateInputs(month, year, dayOfWeek) {
    if (month < 1 || month > 12) {
        throw new Error('Month must be between 1 and 12');
    }
    if (year < 1900 || year > 2100) {
        throw new Error('Year must be between 1900 and 2100');
    }
    if (dayOfWeek < 0 || dayOfWeek > 6) {
        throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
    }
}
function validateOccurrence(occurrence) {
    if (occurrence === 0) {
        throw new Error('Occurrence cannot be 0. Use positive numbers for first, second, etc., or negative for last, second-to-last, etc.');
    }
    if (Math.abs(occurrence) > 5) {
        throw new Error('Occurrence must be between -5 and 5 (excluding 0)');
    }
}
function getOccurrenceDescription(occurrence) {
    return occurrence > 0
        ? `${getOrdinalSuffix(occurrence)} occurrence`
        : `${Math.abs(occurrence) === 1 ? 'last' : getOrdinalSuffix(Math.abs(occurrence)) + ' to last'} occurrence`;
}
// Core date finding logic
function findAllDatesForDayOfWeek(month, year, dayOfWeek) {
    const dates = [];
    const daysInMonth = new Date(year, month, 0).getDate();
    for (let day = 1; day <= daysInMonth; day++) {
        const date = new Date(year, month - 1, day);
        if (date.getDay() === dayOfWeek) {
            dates.push(date);
        }
    }
    return dates;
}
// Tool implementations
function generateDates(month, year, dayOfWeek) {
    validateInputs(month, year, dayOfWeek);
    const dates = findAllDatesForDayOfWeek(month, year, dayOfWeek);
    if (dates.length === 0) {
        throw new Error('No dates found for the specified criteria');
    }
    return {
        success: true,
        query: {
            month: MONTHS[month - 1],
            year,
            dayOfWeek: DAYS[dayOfWeek]
        },
        totalDates: dates.length,
        dates: dates.map((date, index) => ({
            index: index + 1,
            ...getDateInfoRelativeToToday(date)
        }))
    };
}
function findNthOccurrence(month, year, dayOfWeek, occurrence) {
    validateInputs(month, year, dayOfWeek);
    validateOccurrence(occurrence);
    const dates = findAllDatesForDayOfWeek(month, year, dayOfWeek);
    if (dates.length === 0) {
        throw new Error(`No ${DAYS[dayOfWeek]}s found in ${MONTHS[month - 1]} ${year}`);
    }
    let targetDate;
    let actualOccurrence;
    if (occurrence > 0) {
        if (occurrence > dates.length) {
            throw new Error(`Only ${dates.length} ${DAYS[dayOfWeek]}s exist in ${MONTHS[month - 1]} ${year}. Cannot find occurrence ${occurrence}`);
        }
        targetDate = dates[occurrence - 1];
        actualOccurrence = occurrence;
    }
    else {
        const fromEnd = Math.abs(occurrence);
        if (fromEnd > dates.length) {
            throw new Error(`Only ${dates.length} ${DAYS[dayOfWeek]}s exist in ${MONTHS[month - 1]} ${year}. Cannot find occurrence ${occurrence}`);
        }
        targetDate = dates[dates.length - fromEnd];
        actualOccurrence = dates.length - fromEnd + 1;
    }
    return {
        success: true,
        query: {
            month: MONTHS[month - 1],
            year,
            dayOfWeek: DAYS[dayOfWeek],
            requestedOccurrence: occurrence,
            occurrenceDescription: getOccurrenceDescription(occurrence)
        },
        totalOccurrences: dates.length,
        foundOccurrence: actualOccurrence,
        date: getDateInfoRelativeToToday(targetDate)
    };
}
function findNthOccurrenceRange(startMonth, endMonth, year, dayOfWeek, occurrence) {
    if (startMonth < 1 || startMonth > 12 || endMonth < 1 || endMonth > 12) {
        throw new Error('Start and end months must be between 1 and 12');
    }
    if (startMonth > endMonth) {
        throw new Error('Start month cannot be greater than end month');
    }
    validateInputs(startMonth, year, dayOfWeek);
    validateOccurrence(occurrence);
    const results = [];
    let successCount = 0;
    for (let month = startMonth; month <= endMonth; month++) {
        try {
            const result = findNthOccurrence(month, year, dayOfWeek, occurrence);
            results.push({
                month: MONTHS[month - 1],
                monthNumber: month,
                ...result
            });
            successCount++;
        }
        catch (error) {
            results.push({
                month: MONTHS[month - 1],
                monthNumber: month,
                success: false,
                message: error instanceof Error ? error.message : 'Unknown error',
                date: null
            });
        }
    }
    return {
        success: successCount > 0,
        query: {
            startMonth: MONTHS[startMonth - 1],
            endMonth: MONTHS[endMonth - 1],
            year,
            dayOfWeek: DAYS[dayOfWeek],
            requestedOccurrence: occurrence,
            occurrenceDescription: getOccurrenceDescription(occurrence)
        },
        totalMonths: endMonth - startMonth + 1,
        successfulMonths: successCount,
        results
    };
}
function findNthOccurrenceYear(year, dayOfWeek, occurrence) {
    return findNthOccurrenceRange(1, 12, year, dayOfWeek, occurrence);
}
function getOptions() {
    const currentYear = new Date().getFullYear();
    const years = Array.from({ length: 201 }, (_, i) => 1900 + i);
    return {
        months: MONTHS.map((month, index) => ({ value: index + 1, name: month })),
        years,
        daysOfWeek: DAYS.map((day, index) => ({ value: index, name: day })),
        currentYear
    };
}
// MCP Server setup
const server = new Server({
    name: 'date-generator-mcp',
    version: '1.0.0',
}, {
    capabilities: {
        tools: {},
    },
});
server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: 'generate_dates',
                description: 'Generate all dates in a given month/year that fall on a specific day of the week',
                inputSchema: {
                    type: 'object',
                    properties: {
                        month: {
                            type: 'number',
                            description: 'Month number (1-12)',
                            minimum: 1,
                            maximum: 12
                        },
                        year: {
                            type: 'number',
                            description: 'Year (e.g., 2024)',
                            minimum: 1900,
                            maximum: 2100
                        },
                        dayOfWeek: {
                            type: 'number',
                            description: 'Day of week (0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)',
                            minimum: 0,
                            maximum: 6
                        }
                    },
                    required: ['month', 'year', 'dayOfWeek']
                }
            },
            {
                name: 'nth_occurrence_finder',
                description: 'Find the nth occurrence of a specific day of the week in a month (e.g., 2nd Tuesday, last Friday)',
                inputSchema: {
                    type: 'object',
                    properties: {
                        month: {
                            type: 'number',
                            description: 'Month number (1-12)',
                            minimum: 1,
                            maximum: 12
                        },
                        year: {
                            type: 'number',
                            description: 'Year (e.g., 2024)',
                            minimum: 1900,
                            maximum: 2100
                        },
                        dayOfWeek: {
                            type: 'number',
                            description: 'Day of week (0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)',
                            minimum: 0,
                            maximum: 6
                        },
                        occurrence: {
                            type: 'number',
                            description: 'Which occurrence (1=first, 2=second, 3=third, etc. OR -1=last, -2=second to last, etc.)',
                            minimum: -5,
                            maximum: 5
                        }
                    },
                    required: ['month', 'year', 'dayOfWeek', 'occurrence']
                }
            },
            {
                name: 'get_options',
                description: 'Get available months, years, and days of week for selection',
                inputSchema: {
                    type: 'object',
                    properties: {}
                }
            },
            {
                name: 'nth_occurrence_range',
                description: 'Find the nth occurrence of a specific day of the week across consecutive months (e.g., "2nd Wednesday Jan-Mar 2025")',
                inputSchema: {
                    type: 'object',
                    properties: {
                        startMonth: {
                            type: 'number',
                            description: 'Start month number (1-12)',
                            minimum: 1,
                            maximum: 12
                        },
                        endMonth: {
                            type: 'number',
                            description: 'End month number (1-12)',
                            minimum: 1,
                            maximum: 12
                        },
                        year: {
                            type: 'number',
                            description: 'Year (e.g., 2024)',
                            minimum: 1900,
                            maximum: 2100
                        },
                        dayOfWeek: {
                            type: 'number',
                            description: 'Day of week (0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)',
                            minimum: 0,
                            maximum: 6
                        },
                        occurrence: {
                            type: 'number',
                            description: 'Which occurrence (1=first, 2=second, 3=third, etc. OR -1=last, -2=second to last, etc.)',
                            minimum: -5,
                            maximum: 5
                        }
                    },
                    required: ['startMonth', 'endMonth', 'year', 'dayOfWeek', 'occurrence']
                }
            },
            {
                name: 'nth_occurrence_year',
                description: 'Find the nth occurrence of a specific day of the week for all 12 months in a year (e.g., "2nd Wednesday every month in 2025")',
                inputSchema: {
                    type: 'object',
                    properties: {
                        year: {
                            type: 'number',
                            description: 'Year (e.g., 2024)',
                            minimum: 1900,
                            maximum: 2100
                        },
                        dayOfWeek: {
                            type: 'number',
                            description: 'Day of week (0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)',
                            minimum: 0,
                            maximum: 6
                        },
                        occurrence: {
                            type: 'number',
                            description: 'Which occurrence (1=first, 2=second, 3=third, etc. OR -1=last, -2=second to last, etc.)',
                            minimum: -5,
                            maximum: 5
                        }
                    },
                    required: ['year', 'dayOfWeek', 'occurrence']
                }
            }
        ]
    };
});
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    try {
        let result;
        switch (name) {
            case 'generate_dates':
                result = generateDates(args.month, args.year, args.dayOfWeek);
                break;
            case 'nth_occurrence_finder':
                result = findNthOccurrence(args.month, args.year, args.dayOfWeek, args.occurrence);
                break;
            case 'get_options':
                result = getOptions();
                break;
            case 'nth_occurrence_range':
                result = findNthOccurrenceRange(args.startMonth, args.endMonth, args.year, args.dayOfWeek, args.occurrence);
                break;
            case 'nth_occurrence_year':
                result = findNthOccurrenceYear(args.year, args.dayOfWeek, args.occurrence);
                break;
            default:
                throw new Error(`Unknown tool: ${name}`);
        }
        return {
            content: [
                {
                    type: 'text',
                    text: JSON.stringify(result, null, 2)
                }
            ]
        };
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
        return {
            content: [
                {
                    type: 'text',
                    text: JSON.stringify({ success: false, error: errorMessage }, null, 2)
                }
            ],
            isError: true
        };
    }
});
// Start server
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error('Date Generator MCP server running on stdio');
}
main().catch((error) => {
    console.error('Server error:', error);
    process.exit(1);
});
