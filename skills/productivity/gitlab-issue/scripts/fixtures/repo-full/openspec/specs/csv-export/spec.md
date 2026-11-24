## Purpose

Lets a billing admin download invoices as a CSV file.
The download covers the filters currently applied.

## Requirements

### Requirement: Download current view
The system SHALL export the rows shown.

#### Scenario: Filtered export
- **WHEN** the admin exports with a date filter
- **THEN** only matching invoices are in the file

#### Scenario: Empty export
- **WHEN** no invoices match
- **THEN** the file holds only the header row

### Requirement: Large exports
The system SHALL finish large exports in the background.

#### Scenario: Over the row limit
- **WHEN** more than 10000 rows match
- **THEN** the admin is emailed a link
