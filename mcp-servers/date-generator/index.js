#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// Arrays for data (extracted from your original JavaScript)
const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

/**
 * Core date generation logic (adapted from your generateDates function)
 * @param {number} month - Month number (1-12)
 * @param {number} year - Year (e.g., 2024)
 * @param {number} dayOfWeek - Day of week (0=Sunday, 1=Monday, etc.)
 * @returns {Object} Object containing dates and metadata
 */
function generateDatesForDayOfWeek(month, year, dayOfWeek) {
  // Input validation
  if (month < 1 || month > 12) {
    throw new Error('Month must be between 1 and 12');
  }
  if (year < 1900 || year > 2100) {
    throw new Error('Year must be between 1900 and 2100');
  }
  if (dayOfWeek < 0 || dayOfWeek > 6) {
    throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
  }

  const dates = [];
  const daysInMonth = new Date(year, month, 0).getDate();

  // Find all dates in the month that match the selected day of week
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month - 1, day);
    if (date.getDay() === dayOfWeek) {
      dates.push(date);
    }
  }

  if (dates.length === 0) {
    return {
      success: false,
      message: 'No dates found for the specified criteria.',
      dates: []
    };
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Format dates with additional metadata
  const formattedDates = dates.map((date, index) => {
    const formattedDate = date.toLocaleDateString('en-US', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
    
    const daysFromToday = Math.floor((date - today) / (1000 * 60 * 60 * 24));
    const weeksFromToday = (daysFromToday / 7).toFixed(2);

    return {
      index: index + 1,
      date: date.toISOString().split('T')[0], // YYYY-MM-DD format
      formatted: formattedDate,
      daysFromToday: daysFromToday,
      weeksFromToday: parseFloat(weeksFromToday),
      isPast: daysFromToday < 0,
      isToday: daysFromToday === 0,
      isFuture: daysFromToday > 0
    };
  });

  return {
    success: true,
    query: {
      month: months[month - 1],
      year: year,
      dayOfWeek: days[dayOfWeek]
    },
    totalDates: dates.length,
    dates: formattedDates
  };
}

/**
 * Find the nth occurrence of a specific day of the week in a month
 * @param {number} month - Month number (1-12)
 * @param {number} year - Year (e.g., 2024)
 * @param {number} dayOfWeek - Day of week (0=Sunday, 1=Monday, etc.)
 * @param {number} occurrence - Which occurrence (1=first, 2=second, -1=last, -2=second to last)
 * @returns {Object} Object containing the found date and metadata
 */
function findNthOccurrence(month, year, dayOfWeek, occurrence) {
  // Input validation
  if (month < 1 || month > 12) {
    throw new Error('Month must be between 1 and 12');
  }
  if (year < 1900 || year > 2100) {
    throw new Error('Year must be between 1900 and 2100');
  }
  if (dayOfWeek < 0 || dayOfWeek > 6) {
    throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
  }
  if (occurrence === 0) {
    throw new Error('Occurrence cannot be 0. Use positive numbers for first, second, etc., or negative for last, second-to-last, etc.');
  }
  if (Math.abs(occurrence) > 5) {
    throw new Error('Occurrence must be between -5 and 5 (excluding 0)');
  }

  const dates = [];
  const daysInMonth = new Date(year, month, 0).getDate();

  // Find all dates in the month that match the selected day of week
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month - 1, day);
    if (date.getDay() === dayOfWeek) {
      dates.push(date);
    }
  }

  if (dates.length === 0) {
    return {
      success: false,
      message: 'No dates found for the specified day of week in this month.',
      date: null
    };
  }

  let targetDate;
  let actualOccurrence;

  if (occurrence > 0) {
    // Positive occurrence (1st, 2nd, 3rd, etc.)
    if (occurrence > dates.length) {
      return {
        success: false,
        message: `Only ${dates.length} ${days[dayOfWeek]}s exist in ${months[month - 1]} ${year}. Cannot find occurrence ${occurrence}.`,
        totalOccurrences: dates.length,
        date: null
      };
    }
    targetDate = dates[occurrence - 1];
    actualOccurrence = occurrence;
  } else {
    // Negative occurrence (-1=last, -2=second to last, etc.)
    const fromEnd = Math.abs(occurrence);
    if (fromEnd > dates.length) {
      return {
        success: false,
        message: `Only ${dates.length} ${days[dayOfWeek]}s exist in ${months[month - 1]} ${year}. Cannot find occurrence ${occurrence}.`,
        totalOccurrences: dates.length,
        date: null
      };
    }
    targetDate = dates[dates.length - fromEnd];
    actualOccurrence = dates.length - fromEnd + 1; // Convert to positive occurrence for display
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const daysFromToday = Math.floor((targetDate - today) / (1000 * 60 * 60 * 24));
  const weeksFromToday = (daysFromToday / 7).toFixed(2);

  const formattedDate = targetDate.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });

  const ordinalSuffix = (num) => {
    const suffixes = ['th', 'st', 'nd', 'rd'];
    const value = num % 100;
    return num + (suffixes[(value - 20) % 10] || suffixes[value] || suffixes[0]);
  };

  return {
    success: true,
    query: {
      month: months[month - 1],
      year: year,
      dayOfWeek: days[dayOfWeek],
      requestedOccurrence: occurrence,
      occurrenceDescription: occurrence > 0 ? 
        `${ordinalSuffix(occurrence)} occurrence` : 
        `${Math.abs(occurrence) === 1 ? 'last' : ordinalSuffix(Math.abs(occurrence)) + ' to last'} occurrence`
    },
    totalOccurrences: dates.length,
    foundOccurrence: actualOccurrence,
    date: {
      date: targetDate.toISOString().split('T')[0], // YYYY-MM-DD format
      formatted: formattedDate,
      daysFromToday: daysFromToday,
      weeksFromToday: parseFloat(weeksFromToday),
      isPast: daysFromToday < 0,
      isToday: daysFromToday === 0,
      isFuture: daysFromToday > 0
    }
  };
}

/**
 * Validate month range
 * @param {number} startMonth - Start month (1-12)
 * @param {number} endMonth - End month (1-12)
 */
function validateMonthRange(startMonth, endMonth) {
  if (startMonth < 1 || startMonth > 12) {
    throw new Error('Start month must be between 1 and 12');
  }
  if (endMonth < 1 || endMonth > 12) {
    throw new Error('End month must be between 1 and 12');
  }
  if (startMonth > endMonth) {
    throw new Error('Start month cannot be greater than end month');
  }
}

/**
 * Find nth occurrence across a range of consecutive months
 * @param {number} startMonth - Start month (1-12)
 * @param {number} endMonth - End month (1-12)
 * @param {number} year - Year (e.g., 2024)
 * @param {number} dayOfWeek - Day of week (0=Sunday, 1=Monday, etc.)
 * @param {number} occurrence - Which occurrence (1=first, 2=second, -1=last, -2=second to last)
 * @returns {Object} Object containing results for each month
 */
function findNthOccurrenceRange(startMonth, endMonth, year, dayOfWeek, occurrence) {
  // Input validation
  validateMonthRange(startMonth, endMonth);
  if (year < 1900 || year > 2100) {
    throw new Error('Year must be between 1900 and 2100');
  }
  if (dayOfWeek < 0 || dayOfWeek > 6) {
    throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
  }
  if (occurrence === 0) {
    throw new Error('Occurrence cannot be 0. Use positive numbers for first, second, etc., or negative for last, second-to-last, etc.');
  }
  if (Math.abs(occurrence) > 5) {
    throw new Error('Occurrence must be between -5 and 5 (excluding 0)');
  }

  const results = [];
  let successCount = 0;
  
  for (let month = startMonth; month <= endMonth; month++) {
    const monthResult = findNthOccurrence(month, year, dayOfWeek, occurrence);
    results.push({
      month: months[month - 1],
      monthNumber: month,
      ...monthResult
    });
    
    if (monthResult.success) {
      successCount++;
    }
  }

  const ordinalSuffix = (num) => {
    const suffixes = ['th', 'st', 'nd', 'rd'];
    const value = num % 100;
    return num + (suffixes[(value - 20) % 10] || suffixes[value] || suffixes[0]);
  };

  return {
    success: successCount > 0,
    query: {
      startMonth: months[startMonth - 1],
      endMonth: months[endMonth - 1],
      year: year,
      dayOfWeek: days[dayOfWeek],
      requestedOccurrence: occurrence,
      occurrenceDescription: occurrence > 0 ? 
        `${ordinalSuffix(occurrence)} occurrence` : 
        `${Math.abs(occurrence) === 1 ? 'last' : ordinalSuffix(Math.abs(occurrence)) + ' to last'} occurrence`
    },
    totalMonths: endMonth - startMonth + 1,
    successfulMonths: successCount,
    results: results
  };
}

/**
 * Find nth occurrence for all 12 months in a year
 * @param {number} year - Year (e.g., 2024)
 * @param {number} dayOfWeek - Day of week (0=Sunday, 1=Monday, etc.)
 * @param {number} occurrence - Which occurrence (1=first, 2=second, -1=last, -2=second to last)
 * @returns {Object} Object containing results for all 12 months
 */
function findNthOccurrenceYear(year, dayOfWeek, occurrence) {
  // Input validation
  if (year < 1900 || year > 2100) {
    throw new Error('Year must be between 1900 and 2100');
  }
  if (dayOfWeek < 0 || dayOfWeek > 6) {
    throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
  }
  if (occurrence === 0) {
    throw new Error('Occurrence cannot be 0. Use positive numbers for first, second, etc., or negative for last, second-to-last, etc.');
  }
  if (Math.abs(occurrence) > 5) {
    throw new Error('Occurrence must be between -5 and 5 (excluding 0)');
  }

  const results = [];
  let successCount = 0;
  
  for (let month = 1; month <= 12; month++) {
    const monthResult = findNthOccurrence(month, year, dayOfWeek, occurrence);
    results.push({
      month: months[month - 1],
      monthNumber: month,
      ...monthResult
    });
    
    if (monthResult.success) {
      successCount++;
    }
  }

  const ordinalSuffix = (num) => {
    const suffixes = ['th', 'st', 'nd', 'rd'];
    const value = num % 100;
    return num + (suffixes[(value - 20) % 10] || suffixes[value] || suffixes[0]);
  };

  return {
    success: successCount > 0,
    query: {
      year: year,
      dayOfWeek: days[dayOfWeek],
      requestedOccurrence: occurrence,
      occurrenceDescription: occurrence > 0 ? 
        `${ordinalSuffix(occurrence)} occurrence` : 
        `${Math.abs(occurrence) === 1 ? 'last' : ordinalSuffix(Math.abs(occurrence)) + ' to last'} occurrence`
    },
    totalMonths: 12,
    successfulMonths: successCount,
    results: results
  };
}

/**
 * Get available months, years, and days of week
 * @returns {Object} Available options
 */
function getAvailableOptions() {
  const currentYear = new Date().getFullYear();
  const minYear = 1900;
  const maxYear = 2100;
  const years = Array.from({ length: maxYear - minYear + 1 }, (_, i) => minYear + i);
  
  return {
    months: months.map((month, index) => ({ value: index + 1, name: month })),
    years: years,
    daysOfWeek: days.map((day, index) => ({ value: index, name: day })),
    currentYear: currentYear
  };
}

// Create the MCP server
const server = new Server(
  {
    name: 'date-generator-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
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

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'generate_dates':
        const { month, year, dayOfWeek } = args;
        const result = generateDatesForDayOfWeek(month, year, dayOfWeek);
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2)
            }
          ]
        };

      case 'nth_occurrence_finder':
        const { month: nthMonth, year: nthYear, dayOfWeek: nthDayOfWeek, occurrence } = args;
        const nthResult = findNthOccurrence(nthMonth, nthYear, nthDayOfWeek, occurrence);
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(nthResult, null, 2)
            }
          ]
        };

      case 'get_options':
        const options = getAvailableOptions();
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(options, null, 2)
            }
          ]
        };

      case 'nth_occurrence_range':
        const { startMonth, endMonth, year: rangeYear, dayOfWeek: rangeDayOfWeek, occurrence: rangeOccurrence } = args;
        const rangeResult = findNthOccurrenceRange(startMonth, endMonth, rangeYear, rangeDayOfWeek, rangeOccurrence);
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(rangeResult, null, 2)
            }
          ]
        };

      case 'nth_occurrence_year':
        const { year: yearYear, dayOfWeek: yearDayOfWeek, occurrence: yearOccurrence } = args;
        const yearResult = findNthOccurrenceYear(yearYear, yearDayOfWeek, yearOccurrence);
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(yearResult, null, 2)
            }
          ]
        };

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error.message}`
        }
      ],
      isError: true
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Date Generator MCP server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
