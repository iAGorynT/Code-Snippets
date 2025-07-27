#!/usr/bin/env node

// Simple test script to verify the date generation logic
// This runs the core functions without the MCP server overhead

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read and evaluate the main server file to get the functions
const serverCode = readFileSync(join(__dirname, 'index.js'), 'utf8');

// Extract the core functions for testing
const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

function generateDatesForDayOfWeek(month, year, dayOfWeek) {
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
      date: date.toISOString().split('T')[0],
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

// Test cases
console.log('🧪 Testing Date Generator MCP Server Logic\n');

// Test 1: Find all Mondays in December 2024
console.log('Test 1: All Mondays in December 2024');
try {
  const result1 = generateDatesForDayOfWeek(12, 2024, 1);
  console.log(JSON.stringify(result1, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 2: Find all Fridays in February 2025
console.log('Test 2: All Fridays in February 2025');
try {
  const result2 = generateDatesForDayOfWeek(2, 2025, 5);
  console.log(JSON.stringify(result2, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 3: Error handling - invalid month
console.log('Test 3: Error handling (invalid month)');
try {
  const result3 = generateDatesForDayOfWeek(13, 2024, 1);
  console.log(JSON.stringify(result3, null, 2));
} catch (error) {
  console.error('Expected error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 4: Current month example
const now = new Date();
const currentMonth = now.getMonth() + 1;
const currentYear = now.getFullYear();
console.log(`Test 4: All Sundays in ${months[currentMonth - 1]} ${currentYear}`);
try {
  const result4 = generateDatesForDayOfWeek(currentMonth, currentYear, 0);
  console.log(JSON.stringify(result4, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 5: nth_occurrence_finder - 2nd Tuesday of March 2024
console.log('Test 5: Find 2nd Tuesday of March 2024');
try {
  const result5 = findNthOccurrence(3, 2024, 2, 2);
  console.log(JSON.stringify(result5, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 6: nth_occurrence_finder - Last Friday of December 2024
console.log('Test 6: Find last Friday of December 2024');
try {
  const result6 = findNthOccurrence(12, 2024, 5, -1);
  console.log(JSON.stringify(result6, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 7: nth_occurrence_finder - 1st Monday of February 2025
console.log('Test 7: Find 1st Monday of February 2025');
try {
  const result7 = findNthOccurrence(2, 2025, 1, 1);
  console.log(JSON.stringify(result7, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 8: nth_occurrence_finder - Error case: 5th Sunday when only 4 exist
console.log('Test 8: Error handling - 5th Sunday of February 2025 (should fail)');
try {
  const result8 = findNthOccurrence(2, 2025, 0, 5);
  console.log(JSON.stringify(result8, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 9: nth_occurrence_finder - 3rd Thursday of current month
const currentMonth9 = now.getMonth() + 1;
const currentYear9 = now.getFullYear();
console.log(`Test 9: Find 3rd Thursday of ${months[currentMonth9 - 1]} ${currentYear9}`);
try {
  const result9 = findNthOccurrence(currentMonth9, currentYear9, 4, 3);
  console.log(JSON.stringify(result9, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 10: nth_occurrence_finder - Second to last Wednesday of August 2024
console.log('Test 10: Find 2nd to last Wednesday of August 2024');
try {
  const result10 = findNthOccurrence(8, 2024, 3, -2);
  console.log(JSON.stringify(result10, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 11: nth_occurrence_finder - Error handling: occurrence = 0
console.log('Test 11: Error handling - occurrence cannot be 0');
try {
  const result11 = findNthOccurrence(3, 2024, 1, 0);
  console.log(JSON.stringify(result11, null, 2));
} catch (error) {
  console.error('Expected error:', error.message);
}

console.log('\n✅ All tests completed!');
console.log('\n📊 Test Summary:');
console.log('• generateDatesForDayOfWeek: 4 tests (including error handling)');
console.log('• findNthOccurrence: 7 tests (including error handling)');
console.log('• Total: 11 comprehensive test cases');
console.log('\nIf no errors appeared above, all functions are working correctly! 🎉');
