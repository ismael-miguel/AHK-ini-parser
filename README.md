# AHK-ini-parser

Parser for .ini files, as an alternative for the IniRead, IniWrite and IniDelete functions.

This makes it really easy to read, change and save values, while reducing the readings/writtings to disk.

<hr>

## How to use

This script creates a class, which takes the file path as a parameter.

Example of usage:

```ahk
#Include, ini.ahk

ini := new Ini(A_ScriptDir . "\" . A_ScriptName . ".ini")

ini.Set("tickcount", "settings", A_TickCount)

ini.Save()
```

If you don't want to define a file yet, you can do like this:

```ahk
#Include, ini.ahk

ini := new Ini("") ; empty string required by the language

ini.Set("tickcount", "settings", A_TickCount)

ini.SaveFile(A_ScriptDir . "\" . A_ScriptName . ".ini")
```

Both methods work exactly the same.

They should create a file that looks like this:

```ini
[settings]
tickcount=123456789
```

<hr>

## Methods

 - `IniFile()`  
	Returns the file path.  

 - `LoadString(string)`  
	Loads a string instead of a file.  

 - `Save()`  
    Saves the file.  
	This can only be used when a file name is passed when instancing.  

 - `SaveFile(string)`  
	Saves the file passed.  
	This is **REQUIRED** to be used when passing an empty string when instancing.  
	
 - `Get(value_name, section_name, default_value)`  
	Retrieves a value from a section.  
	If the value doesn't exist, returns the `default_value`.  
	`section_name` can be an empty string.  
	
 - `Set(value_name, section_name, value)`  
	Sets the value in a section.  
	`section_name` can be an empty string.  
	
 - `Delete(value_name, section_name)`  
	Deletes the value in a section.  
	`section_name` can be an empty string.  
	
 - `DeleteSection(section_name)`  
	Deletes a section and all the values in it.  
	`section_name` can be an empty string.  

 - `Exists(value_name, section_name)`  
	Checks if the value and section exist.  
	`section_name` can be an empty string.  

 - `ExistsSection(section_name)`  
	Checks if a section exists.  
	`section_name` can be an empty string.  
	
 - `Sections()`  
 	Returns an array with the name of all sections.
	
<hr>

## Feature support

This list isn't final.

|        Feature        | Support? | About                                                                                                                        |
|:---------------------:|:--------:|------------------------------------------------------------------------------------------------------------------------------|
|        Comments       |     ❌    | Maintaining comments is too hard.                                                                                            |
| Values on<br>Sections |     ❌    | This is non-standard, but would be cool.                                                                                     |
|         Arrays        |     ❌    | Too much work for something non-standard.                                                                                    |
|       No section      |     ✔️    | All methods accept an empty string and will generate a file without a section when one isn't provided. This is non-standard! |
|       Whitespace      |     ⚠️    | Currently, doesn't conform with the expected syntax for ini files, but supports some.                                        |
|       Multiline       |     ❌    | All values will be converted to single-lines.                                                                                |
|        Escapes        |     ❌    | No care was taken to parse these.                                                                                            |
