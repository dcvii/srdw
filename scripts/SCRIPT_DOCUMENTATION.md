# NISSAN SRDW Scripts Documentation

## Overview
This directory contains 44 shell scripts that manage an Essbase-based Regional Data Warehouse (SRDW) system for Nissan USA. The system handles financial data processing across multiple applications and environments (Development, QA, Production).

## Script Categories

### 1. Core Orchestration Scripts
**Purpose**: Main workflow coordination and scheduling

#### `poll.sh`
- **Purpose**: Main polling script that processes data tokens and triggers updates
- **Functionality**: 
  - Monitors for different types of tokens (normal, totals, latest, error)
  - Processes multiple applications (patb, locl, rpla, rplb, rplu, rbs, rfem)
  - Calls appropriate duper, mshfab, and update scripts based on token type
  - Environment-specific processing (P=Production, D=Development, Q=QA)
- **Key Features**: Lock mechanism prevents concurrent processing
- **Dependencies**: Requires prepoll.sh, various mshfab*.sh, update.sh, calc.sh

#### `prepoll.sh` 
- **Purpose**: Asynchronous data preparation before main polling
- **Functionality**:
  - Processes incoming data files by data type (RFIN, RBUD, ELIM, PATB)
  - Splits and transforms data files for different applications
  - Creates tokens for poll.sh to process
  - Maintains data registry and handles file archiving
- **Data Streams**: rfin (financial), rbud (budget), elim (eliminations), patb (parts)
- **Companies**: Handles 19 different company codes (ana, das, ims, nna, nmac, etc.)

#### `watcher.sh`
- **Purpose**: Kicks off prepoll.sh for all data streams
- **Functionality**: Calls prepoll.sh for each stream type
- **Streams**: rfin, rbud, patb, locl, elim

### 2. Essbase Update Scripts
**Purpose**: Generate and execute Essbase MaxL/MSH scripts for data loading

#### `mshfab.sh` 
- **Purpose**: Generates standard update MSH scripts for data loading
- **Applications**: rbs, rplu, rplb, rpla, rfem, patb, locl
- **Functionality**: Creates MaxL scripts with import statements for each company/data type

#### `mshfabL.sh`
- **Purpose**: Generates "latest" bucket update scripts
- **Functionality**: Similar to mshfab.sh but processes from latest/ directory

#### `mshfabT.sh` 
- **Purpose**: Generates "totals" update scripts for historical data
- **Functionality**: Processes concatenated historical data files with database reset

#### `mshfabE.sh`
- **Purpose**: Generates error reprocessing scripts
- **Functionality**: Creates outline build and data load scripts for rejected records

#### `update.sh`
- **Purpose**: Executes generated MSH scripts and handles error processing
- **Functionality**: 
  - Runs MSH scripts via essmsh
  - Processes load errors for each application type
  - Creates error tokens for reprocessing
  - Sends email notifications

#### `updateE.sh`
- **Purpose**: Processes error tokens and reloads rejected data
- **Functionality**: Executes error MSH scripts and reports success/failure

### 3. Data Movement Scripts
**Purpose**: Copy and organize data files between directories and applications

#### `duperL.sh` 
- **Purpose**: Copies "latest" data files to Essbase application directories
- **Applications**: rbs, rfem, rpla, rplb, rplu, patb, locl
- **Functionality**: File validation, logging, email reporting

#### `duperN.sh`
- **Purpose**: Copies "normal" data files to application directories  
- **Functionality**: Similar to duperL.sh but for current month data

#### `duperT.sh`
- **Purpose**: Copies "totals" (historical) data files
- **Functionality**: Creates concatenated historical files before copying

#### `cleanup.sh`
- **Purpose**: Moves processed files to latest/ directory
- **Functionality**: Organizes files by type and removes tokens

#### `supercat.sh`
- **Purpose**: Concatenates files across monthly buckets for historical loads
- **Parameters**: Takes file root name as parameter
- **Functionality**: Creates "T" (totals) files from monthly data

### 4. Application Management Scripts  
**Purpose**: Essbase application lifecycle management

#### `calc.sh`
- **Purpose**: Executes Essbase calculations for applications
- **Applications**: mex6, rbs, rbsc, rfem, rx10, rx11, rpla, rplb, rplc, rplu, locl, patb
- **Functionality**: Generates and executes calculation MSH scripts

#### `calcer.sh`
- **Purpose**: Batch calculation executor
- **Functionality**: Runs calc.sh for environment-specific application lists

#### `backup.sh`
- **Purpose**: Creates application backups with data exports
- **Functionality**: 
  - Exports data in 4-part splits
  - Creates tar/zip archives with metadata
  - Stores backups locally and remotely via FTP
  - Handles build versioning

#### `backer.sh`
- **Purpose**: Batch backup executor for all live applications
- **Applications**: locl, rbs, patb, rpla, rplb, rplu, rfem

#### `export.sh`
- **Purpose**: Exports application data and objects separately
- **Functionality**: Similar to backup.sh but creates separate object/data archives

#### `exporter.sh` 
- **Purpose**: Batch exporter for multiple applications
- **Applications**: locl, rbs, patb, rfem, rpla, rplu

#### `restore.sh`
- **Purpose**: Restores application data from export files
- **Functionality**: 
  - Extracts and imports 4-part data exports
  - Resets database before import
  - Handles build version validation

#### `restorer.sh`
- **Purpose**: Batch restore executor for all applications

### 5. Migration and Synchronization Scripts
**Purpose**: Move applications and data between environments

#### `migrate.sh`
- **Purpose**: Migrates applications from DEV to current environment
- **Functionality**: 
  - Fetches objects and data exports via FTP
  - Updates local application with DEV version
  - Handles version file synchronization

#### `migrateQ.sh`
- **Purpose**: Migrates applications from QA to current environment
- **Functionality**: Similar to migrate.sh but sources from QA

#### `migrateQer.sh`
- **Purpose**: Batch migration executor from QA
- **Applications**: locl, rbs, patb, rpla, rplb, rfem, rplu

#### `snatch.sh`
- **Purpose**: Downloads data files from other environments
- **Parameters**: source environment, bucket name
- **Environments**: qa, prod, dev
- **Buckets**: Monthly (2002-12 through 2003-06), totals, budgets, latest

#### `snatcher.sh`
- **Purpose**: Batch downloader calling snatch.sh for all buckets

#### `grabqaData.sh`
- **Purpose**: Specialized script to download QA data for specific periods

### 6. Utility and Helper Scripts
**Purpose**: Support functions and system utilities

#### `a.sh`
- **Purpose**: Simple test script checking parameter value
- **Functionality**: Basic conditional logic test

#### `PRD_RPLC.sh`
- **Purpose**: Executes PRD_RPLC.msh MaxL script
- **Functionality**: Single-line script runner

#### `combo.sh`  
- **Purpose**: Generates inter-company combination lists
- **Functionality**: Creates buyer/seller intercompany combinations

#### `parser.sh`
- **Purpose**: Parses Essbase application logs for statistics
- **Applications**: PATB, LOCL, RPL, RBS, RBSC, RPLA, RPLB
- **Functionality**: Extracts and emails query statistics

#### `spush.sh`
- **Purpose**: Deploys scripts from DEV to QA and PROD environments
- **Functionality**: FTP-based script deployment with version files

#### `stats.sh`
- **Purpose**: Displays Essbase database statistics
- **Applications**: rfem, rbs, rpla, rplb, rplu, patb, locl
- **Functionality**: Uses ESSCMD to get database info

#### `swap.sh`
- **Purpose**: Duplicates applications to APP2 versions (ST vs UAT)
- **Applications**: rbs, rplc, rplu, patb, locl
- **Functionality**: Uses ESSCMD copydb command

#### `unswap.sh`
- **Purpose**: Reverses swap operation (APP2 back to APP)
- **Functionality**: Opposite of swap.sh

#### `wipe.sh`
- **Purpose**: Removes all processing tokens for testing
- **Functionality**: Cleans token files from input directories

### 7. Monitoring and Reporting Scripts
**Purpose**: System health checks and status reporting

#### `bchek.sh`
- **Purpose**: Checks data bucket contents and file status
- **Parameters**: bucket name (latest, budgets, monthly)
- **Functionality**: Validates file presence and timestamps

#### `dchek.sh`  
- **Purpose**: Displays data run information for specified date
- **Functionality**: Extracts and sorts registry data by date, type, company

#### `vchek.sh`
- **Purpose**: Displays version information for all applications
- **Functionality**: Shows version files and recent activity

#### `version.sh`
- **Purpose**: Updates version files and creates versioned archives
- **Types**: Script archives (srdw) and application metadata
- **Functionality**: Auto-increments versions, creates archives

#### `rschek.sh` / `checkReportsServer.sh`
- **Purpose**: Monitors Hyperion Reports Server availability
- **Functionality**: HTTP health checks with email alerts

#### `webchek.sh`
- **Purpose**: Perl-based web server response checker
- **Functionality**: Checks HTTP 200 OK responses

#### `secupdate.sh`
- **Purpose**: Updates Essbase security settings
- **Functionality**: Runs keymaster.msh and gatekeeper.msh

### 8. Specialized Application Scripts
**Purpose**: Application-specific processing

#### `rfemx.sh` 
- **Purpose**: RFEM elimination data extraction for closed loop
- **Functionality**: 
  - Exports data in column format
  - Creates tokens for downstream processing
  - Handles manual elimination entries

## Environment Configuration

### Directory Structure
All scripts use dynamic disk configuration:
- **Scripts**: `/${disk}03/essbase/rdwmr/scripts/`
- **Input**: `/${disk}03/essbase/rdwmr/input/`
- **Logs**: `/${disk}03/essbase/rdwmr/logs/`
- **Errors**: `/${disk}03/essbase/rdwmr/errlogs/`
- **Export**: `/${disk}03/essbase/rdwmr/export/`
- **Applications**: `/${disk}01/vendors/essbase/app/`
- **Binaries**: `/${disk}01/vendors/essbase/bin/`

### Environment Detection
Scripts detect environment via `env.dat` file:
- **P** = Production (143 server)
- **Q** = QA (146 server)  
- **D** = Development (193 server)

### Application Mapping
- **PATB**: Parts application
- **LOCL**: Local currency reporting
- **RBS**: Regional budget system
- **RPLA/RPLB**: Regional P&L applications
- **RPLU**: Regional P&L unified
- **RFEM**: Regional financial eliminations
- **RPLC**: Regional P&L consolidated

### Company Codes
System processes 19 companies:
`ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci`

### File Extensions
- **6**: 6-digit account codes
- **6p**: P&L subset of 6-digit codes  
- **9**: 9-digit account codes
- **_b**: Budget versions
- **_e**: Elimination files
- **_p**: Parts-specific files
- **T**: Historical totals (concatenated)

## Error Handling
- Comprehensive error logging to `errlogs/` directory
- Email notifications to specified recipients
- Error token creation for reprocessing
- Archive mechanisms for processed files
- Lock files prevent concurrent execution

## Integration Points
- **FTP**: Inter-environment file transfer
- **Email**: Status notifications via mailx
- **Essbase**: MaxL/MSH script execution via essmsh
- **Archive**: Perl scripts for file compression/organization
- **Registry**: Perl-based logging of data processing events

This system represents a comprehensive ETL and data warehouse management solution for Essbase-based financial reporting at enterprise scale.