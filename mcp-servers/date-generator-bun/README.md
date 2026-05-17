# Date Generator MCP Server

This MCP server provides tools for generating dates based on month, year, and day of week criteria. It's converted from the original HTML/CSS/JavaScript date generator web application.

## Features

- Generate all dates in a specific month/year that fall on a chosen day of the week
- Find the nth occurrence of a specific day of the week in a month (e.g., 2nd Tuesday, last Friday)
- Get available options for months, years, and days of week
- Includes metadata like days from today, weeks from today, and past/future indicators
- Input validation and error handling

## Installation

1. Navigate to the project directory:
   ```bash
   cd /Users/bruceguthrie/Desktop/claude_workspace/new/date-generator-mcp
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

## Usage

### Running the Server

```bash
npm start
```

Or for development with auto-restart:
```bash
npm run dev
```

### Available Tools

#### 1. `generate_dates`
Generates all dates in a given month/year that fall on a specific day of the week.

**Parameters:**
- `month` (number): Month number (1-12)
- `year` (number): Year (e.g., 2024)
- `dayOfWeek` (number): Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)

**Example:**
```json
{
  "month": 12,
  "year": 2024,
  "dayOfWeek": 1
}
```

**Response:**
```json
{
  "success": true,
  "query": {
    "month": "December",
    "year": 2024,
    "dayOfWeek": "Monday"
  },
  "totalDates": 5,
  "dates": [
    {
      "index": 1,
      "date": "2024-12-02",
      "formatted": "Monday, December 2, 2024",
      "daysFromToday": 139,
      "weeksFromToday": 19.86,
      "isPast": false,
      "isToday": false,
      "isFuture": true
    }
    // ... more dates
  ]
}
```

#### 2. `nth_occurrence_finder`
Find the nth occurrence of a specific day of the week in a month (e.g., 2nd Tuesday, last Friday).

**Parameters:**
- `month` (number): Month number (1-12)
- `year` (number): Year (e.g., 2024)
- `dayOfWeek` (number): Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
- `occurrence` (number): Which occurrence (1=first, 2=second, 3=third, etc. OR -1=last, -2=second to last, etc.)

**Example - Find 2nd Tuesday of March 2024:**
```json
{
  "month": 3,
  "year": 2024,
  "dayOfWeek": 2,
  "occurrence": 2
}
```

**Example - Find last Friday of December 2024:**
```json
{
  "month": 12,
  "year": 2024,
  "dayOfWeek": 5,
  "occurrence": -1
}
```

**Response:**
```json
{
  "success": true,
  "query": {
    "month": "March",
    "year": 2024,
    "dayOfWeek": "Tuesday",
    "requestedOccurrence": 2,
    "occurrenceDescription": "2nd occurrence"
  },
  "totalOccurrences": 4,
  "foundOccurrence": 2,
  "date": {
    "date": "2024-03-12",
    "formatted": "Tuesday, March 12, 2024",
    "daysFromToday": -503,
    "weeksFromToday": -71.86,
    "isPast": true,
    "isToday": false,
    "isFuture": false
  }
}
```

**Error Response Example:**
```json
{
  "success": false,
  "message": "Only 4 Sundays exist in February 2025. Cannot find occurrence 5.",
  "totalOccurrences": 4,
  "date": null
}
```

#### 3. `get_options`
Gets available months, years, and days of week for selection.

**Parameters:** None

**Response:**
```json
{
  "months": [
    { "value": 1, "name": "January" },
    { "value": 2, "name": "February" },
    // ... all months
  ],
  "years": [2020, 2021, 2022, ..., 2050],
  "daysOfWeek": [
    { "value": 0, "name": "Sunday" },
    { "value": 1, "name": "Monday" },
    // ... all days
  ],
  "currentYear": 2025
}
```

#### 4. `nth_occurrence_range`
Find the nth occurrence of a specific day of the week across consecutive months (e.g., "2nd Wednesday Jan-Mar 2025").

**Parameters:**
- `startMonth` (number): Start month number (1-12)
- `endMonth` (number): End month number (1-12)
- `year` (number): Year (e.g., 2024)
- `dayOfWeek` (number): Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
- `occurrence` (number): Which occurrence (1=first, 2=second, 3=third, etc. OR -1=last, -2=second to last, etc.)

**Example - Find 2nd Wednesday from January to March 2025:**
```json
{
  "startMonth": 1,
  "endMonth": 3,
  "year": 2025,
  "dayOfWeek": 3,
  "occurrence": 2
}
```

**Response:**
```json
{
  "success": true,
  "query": {
    "startMonth": "January",
    "endMonth": "March",
    "year": 2025,
    "dayOfWeek": "Wednesday",
    "requestedOccurrence": 2,
    "occurrenceDescription": "2nd occurrence"
  },
  "totalMonths": 3,
  "successfulMonths": 3,
  "results": [
    {
      "month": "January",
      "monthNumber": 1,
      "success": true,
      "query": {
        "month": "January",
        "year": 2025,
        "dayOfWeek": "Wednesday",
        "requestedOccurrence": 2,
        "occurrenceDescription": "2nd occurrence"
      },
      "totalOccurrences": 5,
      "foundOccurrence": 2,
      "date": {
        "date": "2025-01-08",
        "formatted": "Wednesday, January 8, 2025",
        "daysFromToday": -205,
        "weeksFromToday": -29.29,
        "isPast": true,
        "isToday": false,
        "isFuture": false
      }
    }
    // ... results for February and March
  ]
}
```

#### 5. `nth_occurrence_year`
Find the nth occurrence of a specific day of the week for all 12 months in a year (e.g., "2nd Wednesday every month in 2025").

**Parameters:**
- `year` (number): Year (e.g., 2024)
- `dayOfWeek` (number): Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
- `occurrence` (number): Which occurrence (1=first, 2=second, 3=third, etc. OR -1=last, -2=second to last, etc.)

**Example - Find 1st Tuesday of every month in 2025:**
```json
{
  "year": 2025,
  "dayOfWeek": 2,
  "occurrence": 1
}
```

**Response:**
```json
{
  "success": true,
  "query": {
    "year": 2025,
    "dayOfWeek": "Tuesday",
    "requestedOccurrence": 1,
    "occurrenceDescription": "1st occurrence"
  },
  "totalMonths": 12,
  "successfulMonths": 12,
  "results": [
    {
      "month": "January",
      "monthNumber": 1,
      "success": true,
      "query": {
        "month": "January",
        "year": 2025,
        "dayOfWeek": "Tuesday",
        "requestedOccurrence": 1,
        "occurrenceDescription": "1st occurrence"
      },
      "totalOccurrences": 5,
      "foundOccurrence": 1,
      "date": {
        "date": "2025-01-07",
        "formatted": "Tuesday, January 7, 2025",
        "daysFromToday": -206,
        "weeksFromToday": -29.43,
        "isPast": true,
        "isToday": false,
        "isFuture": false
      }
    }
    // ... results for all 12 months
  ]
}
```

**Error Response Example:**
```json
{
  "success": false,
  "query": {
    "year": 2025,
    "dayOfWeek": "Saturday",
    "requestedOccurrence": 5,
    "occurrenceDescription": "5th occurrence"
  },
  "totalMonths": 12,
  "successfulMonths": 4,
  "results": [
    {
      "month": "January",
      "monthNumber": 1,
      "success": false,
      "message": "Only 4 Saturdays exist in January 2025. Cannot find occurrence 5.",
      "totalOccurrences": 4,
      "date": null
    }
    // ... mixed success/failure results for all 12 months
  ]
}
```

## Key Differences from Original Web App

1. **Server-side**: Runs as a Node.js server instead of in the browser
2. **JSON API**: Returns structured JSON data instead of HTML output
3. **MCP Protocol**: Uses Model Context Protocol for tool-based interactions
4. **Enhanced Metadata**: Includes more detailed information about each date
5. **No UI**: Pure data processing without HTML/CSS interface

## Original Logic Preserved

The core date calculation logic from your original `generateDates()` function has been preserved and enhanced:

- Same month/year/day-of-week filtering
- Same date formatting options
- Same "days from today" and "weeks from today" calculations
- Enhanced with additional metadata and better error handling

## Error Handling

The server includes comprehensive input validation:
- Month must be 1-12
- Year must be 1900-2100
- Day of week must be 0-6
- Graceful handling of invalid inputs

## Development Notes

- Uses ES6 modules (`type: "module"` in package.json)
- Includes `--watch` flag for development auto-restart
- Follows MCP server patterns and conventions
- Can be extended with additional date-related tools
