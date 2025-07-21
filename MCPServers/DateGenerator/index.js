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
        name: 'get_options',
        description: 'Get available months, years, and days of week for selection',
        inputSchema: {
          type: 'object',
          properties: {}
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
