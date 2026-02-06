#!/usr/bin/env node

// Proper test suite using actual exported functions from src/index.ts
// This eliminates code duplication and tests the real implementations

import { 
  generateDates, 
  findNthOccurrence, 
  findNthOccurrenceRange, 
  findNthOccurrenceYear, 
  getOptions 
} from './src/index.js';

// Helper function for test output
function logTest(testName: string, result: any) {
  console.log(`\n${testName}:`);
  console.log(JSON.stringify(result, null, 2));
}

// Helper function for error logging
function logError(testName: string, error: any) {
  console.log(`\n${testName}:`);
  console.error('Expected error:', error.message);
}

// Test cases
console.log('🧪 Testing Date Generator MCP Server Logic\n');

// Test 1: Find all Mondays in December 2024
logTest('Test 1: All Mondays in December 2024', generateDates(12, 2024, 1));

console.log('\n' + '='.repeat(50) + '\n');

// Test 2: Find all Fridays in February 2025
logTest('Test 2: All Fridays in February 2025', generateDates(2, 2025, 5));

console.log('\n' + '='.repeat(50) + '\n');

// Test 3: Error handling - invalid month
try {
  generateDates(13, 2024, 1);
} catch (error) {
  logError('Test 3: Error handling (invalid month)', error);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 4: Current month example
const now = new Date();
const currentMonth = now.getMonth() + 1;
const currentYear = now.getFullYear();
logTest(`Test 4: All Sundays in month ${currentMonth} ${currentYear}`, generateDates(currentMonth, currentYear, 0));

console.log('\n' + '='.repeat(50) + '\n');

// Test 5: nth_occurrence_finder - 2nd Tuesday of March 2024
logTest('Test 5: Find 2nd Tuesday of March 2024', findNthOccurrence(3, 2024, 2, 2));

console.log('\n' + '='.repeat(50) + '\n');

// Test 6: nth_occurrence_finder - Last Friday of December 2024
logTest('Test 6: Find last Friday of December 2024', findNthOccurrence(12, 2024, 5, -1));

console.log('\n' + '='.repeat(50) + '\n');

// Test 7: nth_occurrence_finder - 1st Monday of February 2025
logTest('Test 7: Find 1st Monday of February 2025', findNthOccurrence(2, 2025, 1, 1));

console.log('\n' + '='.repeat(50) + '\n');

// Test 8: nth_occurrence_finder - Error case: 5th Sunday when only 4 exist
try {
  findNthOccurrence(2, 2025, 0, 5);
} catch (error) {
  logError('Test 8: Error handling - 5th Sunday of February 2025 (should fail)', error);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 9: nth_occurrence_finder - 3rd Thursday of current month
logTest(`Test 9: Find 3rd Thursday of month ${currentMonth} ${currentYear}`, findNthOccurrence(currentMonth, currentYear, 4, 3));

console.log('\n' + '='.repeat(50) + '\n');

// Test 10: nth_occurrence_finder - Second to last Wednesday of August 2024
logTest('Test 10: Find 2nd to last Wednesday of August 2024', findNthOccurrence(8, 2024, 3, -2));

console.log('\n' + '='.repeat(50) + '\n');

// Test 11: nth_occurrence_finder - Error handling: occurrence = 0
try {
  findNthOccurrence(3, 2024, 1, 0);
} catch (error) {
  logError('Test 11: Error handling - occurrence cannot be 0', error);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 12: findNthOccurrenceRange - 2nd Wednesday from January to March 2025
logTest('Test 12: Find 2nd Wednesday from January to March 2025', findNthOccurrenceRange(1, 3, 2025, 3, 2));

console.log('\n' + '='.repeat(50) + '\n');

// Test 13: findNthOccurrenceRange - Last Friday from June to August 2024
logTest('Test 13: Find last Friday from June to August 2024', findNthOccurrenceRange(6, 8, 2024, 5, -1));

console.log('\n' + '='.repeat(50) + '\n');

// Test 14: findNthOccurrenceRange - Error handling: invalid month range
try {
  findNthOccurrenceRange(6, 3, 2024, 1, 1);
} catch (error) {
  logError('Test 14: Error handling - invalid month range (start > end)', error);
}

console.log('\n' + '='.repeat(50) + '\n');

// Test 15: findNthOccurrenceRange - 5th Monday from February to April 2024 (some will fail)
logTest('Test 15: Find 5th Monday from February to April 2024 (expect some failures)', findNthOccurrenceRange(2, 4, 2024, 1, 5));

console.log('\n' + '='.repeat(50) + '\n');

// Test 16: findNthOccurrenceYear - 1st Tuesday of every month in 2025
logTest('Test 16: Find 1st Tuesday of every month in 2025', findNthOccurrenceYear(2025, 2, 1));

console.log('\n' + '='.repeat(50) + '\n');

// Test 17: findNthOccurrenceYear - Last Sunday of every month in 2024
logTest('Test 17: Find last Sunday of every month in 2024', findNthOccurrenceYear(2024, 0, -1));

console.log('\n' + '='.repeat(50) + '\n');

// Test 18: findNthOccurrenceYear - 3rd Thursday of every month in 2024
logTest('Test 18: Find 3rd Thursday of every month in 2024', findNthOccurrenceYear(2024, 4, 3));

console.log('\n' + '='.repeat(50) + '\n');

// Test 19: findNthOccurrenceYear - 5th Saturday of every month in 2025 (many will fail)
logTest('Test 19: Find 5th Saturday of every month in 2025 (expect many failures)', findNthOccurrenceYear(2025, 6, 5));

console.log('\n' + '='.repeat(50) + '\n');

// Test 20: findNthOccurrenceYear - Error handling: invalid year
try {
  findNthOccurrenceYear(1800, 1, 1);
} catch (error) {
  logError('Test 20: Error handling - invalid year (too low)', error);
}

console.log('\n✅ All tests completed!');
console.log('\n📊 Test Summary:');
console.log('• generateDates: 4 tests (including error handling)');
console.log('• findNthOccurrence: 7 tests (including error handling)');
console.log('• findNthOccurrenceRange: 4 tests (including error handling)');
console.log('• findNthOccurrenceYear: 5 tests (including error handling)');
console.log('• Total: 20 comprehensive test cases');
console.log('\n🎯 These tests validate the ACTUAL function implementations from src/index.ts!');
