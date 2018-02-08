## Description:
The project is used to test the database programs automatically. It can help you to build a new test case quickly, easily and efficiently. It supports to validate correctness of code changes, it also can compare the performance of code changes. 

## Requirments:
* Windows 7/10/2008/2012 64bit
* Python 3.5+
* Packages
     - pymssql (2.1.3) +

## Usage:
```DOS
>run.cmd
```

## Configuration:
### 1. conf for DB scripts
- File Name: .\run.cmd
- Example  :
 
```DOS
SET HOSTNAME="localhost"
SET USERNAME="sa"
SET PASSWORD="123456"
SET DATABASENAME="test"
```

### 2. conf for TestCases
- File Name: .\AspiraFocusTCs\PDBC\conf\db.json
- Example  :

```python
{
    "mssql": {
        "type": "MSSQL",
        "version": 2012,
        "hostname": "localhost",
        "port": 1433,
        "username": "sa",
        "password": "123456",
        "databasename": "test"
    }
}
```


## New Test Case Guide:
### specify parameters in tcs
```python
t = [dict(name=assert_sp, timeout=None, args=('dbo.rpt_CurrentInventoryListing_BY_eliu2','dbo.rpt_CurrentInventoryListing', (310001, None,)))]
```
