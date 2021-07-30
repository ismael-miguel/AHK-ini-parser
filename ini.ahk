Class Ini {
	ini_file := ""
	ini_data := {}

	__New(ini_file)
	{
		if ini_file
		{
			this.ini_file := ini_file

			Try
			{
				FileGetAttrib, attrs, %ini_file%
			}
			catch e
			{}

			If (attrs) and (!InStr(attrs, "D"))
			{
				this.ini_data := new Ini.IniData(ini_file)
			}
			else if attrs
			{
				Throw, "Please specify a file name, not a directory"
			}
			else
			{
				this.ini_data := new Ini.IniData("")
			}
		}
		else
		{
			this.ini_data := new Ini.IniData("")
		}
	}

	IniFile()
	{
		return this.ini_file
	}

	LoadString(ini_text)
	{
		data := InI.IniParser.ParseFromString(ini_text)
		this.ini_data.LoadData(data)
	}
	
	Save()
	{
		if this.ini_file
		{
			return InI.IniWriter.Write(this.ini_file, this.ini_data)
		}
		else
		{
			Throw, "Please use SaveFile(ini_file) instead"
		}
	}

	SaveFile(ini_file)
	{
		if ini_file
		{
			return InI.IniWriter.Write(ini_file, this.ini_data)
		}
		else
		{
			return this.Save()
		}
	}
	
	Get(value_name, section_name, default_value)
	{
		if !value_name
		{
			Throw, "Value name can't be empty."
		}

		if this.ini_data.HasValue(value_name, section_name)
		{
			return this.ini_data.GetValue(value_name, section_name)
		}
		else
		{
			return default_value
		}
	}
	
	Set(value_name, section_name, value)
	{
		if !value_name
		{
			Throw, "Value name can't be empty."
		}

		this.ini_data.SetValue(value_name, value, section_name)
	}
	
	Delete(value_name, section_name)
	{
		if value_name
		{
			this.ini_data.DeleteValue(value_name, section_name)
		}
		else
		{
			this.DeleteSection(section_name)
		}
	}

	DeleteSection(section_name)
	{
		this.ini_data.DeleteSection(section_name)
	}

	Exists(value_name, section_name)
	{
		return this.ini_data.HasValue(value_name, section_name)
	}

	ExistsSection(section_name)
	{
		return this.ini_data.HasSection(section_name)
	}

	Sections()
	{
		return this.ini_data.ListSections()
	}


	class IniData {
		data := {}

		__New(ini_file)
		{
			if(ini_file)
			{
				this.LoadData(Ini.IniParser.Parse(ini_file))
			}
		}

		LoadData(data)
		{
			this.data := data
		}


		ListSections()
		{
			sections := []

			for key, value in this.data
			{
				sections.Push(key)
			}

			return sections
		}

		HasSection(section_name)
		{
			return this.data.HasKey(section_name)
		}

		CreateSection(section_name)
		{
			if !this.HasSection(section_name)
			{
				this.data[section_name] := {}
			}
		}

		GetSection(section_name)
		{
			if !this.HasSection(section_name)
			{
				return []
			}

			return this.data[section_name]
		}

		DeleteSection(section_name)
		{
			if this.HasSection(section_name)
			{
				this.data[section_name].Remove()
			}
		}



		ListValues(section_name)
		{
			values := []

			for key, value in this.GetSection(section_name)
			{
				values.Push(key)
			}

			return values
		}

		HasValue(value_name, section_name)
		{
			return ((this.HasSection(section_name)) and (this.data[section_name].HasKey(value_name)))
		}

		SetValue(value_name, value, section_name)
		{
			if !this.HasSection(section_name)
			{
				this.CreateSection(section_name)
			}

			this.data[section_name][value_name] := value
		}

		GetValue(value_name, section_name)
		{
			if !this.HasValue(value_name, section_name)
			{
				this.SetValue(value_name, "", section_name)
			}

			return this.data[section_name][value_name]
		}

		DeleteValue(value_name, section_name)
		{
			if this.HasValue(value_name, section_name)
			{
				this.data[section_name][value_name].Remove()
			}
		}
	}

	class IniParser {
		Parse(ini_file)
		{
			data := {}
			section_name := ""

			Loop, read, %ini_file%
			{
				if !A_LoopReadLine ; empty line - must ignore
				{
					Continue
				}

				parsed_line := InI.IniParser.ParseLine(A_LoopReadLine, section_name)

				if !parsed_line
				{
					continue
				}

				section_name := parsed_line.section

				if !data[section_name]
				{
					data[section_name] := {}
				}
				
				data[section_name] := InI.IniParser.ParsedLineIntoData(parsed_line, data[section_name])
			}

			return data
		}

		ParseFromString(ini_text)
		{
			data := {}
			section_name := ""

			Loop, parse, ini_text, `n, `r
			{
				if !A_LoopField ; empty line - must ignore
				{
					Continue
				}

				parsed_line := InI.IniParser.ParseLine(A_LoopField, section_name)

				if !parsed_line
				{
					continue
				}

				section_name := parsed_line.section

				if !data[section_name]
				{
					data[section_name] := {}
				}
				
				data[section_name] := InI.IniParser.ParsedLineIntoData(parsed_line, data[section_name])
			}

			return data
		}

		ParsedLineIntoData(parsed_line, data)
		{
			if !parsed_line.name
			{
				return {}
			}
			
			data[parsed_line.name] := parsed_line.value
			return data
		}

		ParseLine(ini_line, current_section_name)
		{
			; can't have values with newlines
			line := StrReplace(RegExReplace(ini_line, "^\s+|\s+$"), "`r`n", " ")
			char := SubStr(line, 1, 1) ; WHAT THE FUCK? START INDEX AT 1?????

			if (char == "[") ; section identified - needs () because fuck you, that's why
			{
				section_name := InI.IniParser.ParseSection(line)
				return {"section": section_name, "name": "", "value": ""}
			}
			else
			{
				; otherwise, must be a value
				value := InI.IniParser.ParseValue(line)
				return {"section": current_section_name, "name": value[1], "value": value[2]} ; WHAT THE FUCK IS THIS...
			}
		}

		ParseSection(line)
		{
			; goal - trim the [] from the line
			return RegExReplace(line, "^\[|\]$")
		}

		ParseValue(line)
		{
			; only want to split once, to preserve any values
			values := StrSplit(line, [" = ", " =", "= ", "="], " `t", 2)
			return values
		}
	}

	class IniWriter {
		Write(ini_file, ini_data)
		{
			Try
			{
				file := FileOpen(ini_file, "w")

				; everything without a section is to be stored at the top
				if ini_data.HasSection("")
				{
					file.Write(InI.IniWriter.MakeValues(ini_data.GetSection("")) . "`r`n")
				}

				for key, section_name in ini_data.ListSections()
				{
					; skips the "" section, since it was added before
					if !section_name
					{
						continue
					}

					section := ini_data.GetSection(section_name)
					if section
					{
						line := "[" . section_name . "]`r`n" . InI.IniWriter.MakeValues(section) . "`r`n"
						
						file.Write(line)
					}
				}

				file.Close()

				return True
			}
			catch e
			{
				return False
			}
		}

		MakeValues(data)
		{
			ini_text := ""

			for key, value in data
			{
				ini_text .= key . "=" . value . "`r`n"
			}

			return ini_text
		}
	}
}