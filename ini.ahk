Class Ini {
	ini_file := ""
	ini_data := {}

	__New(ini_file = "")
	{
		ini_file := Trim(ini_file)
		
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
				this.ini_data := new Ini.IniData()
			}
		}
		else
		{
			this.ini_data := new Ini.IniData()
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
		ini_file := Trim(ini_file)
		
		if ini_file
		{
			return InI.IniWriter.Write(ini_file, this.ini_data)
		}
		else
		{
			return this.Save()
		}
	}
	
	Get(value_name, section_name = "", default_value = "")
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		default_value := Trim(default_value)
		
		if !value_name
		{
			Throw, "Value name can't be empty."
		}

		if (this.ini_data.HasValue(value_name, section_name))
		{
			return this.ini_data.GetValue(value_name, section_name)
		}
		else
		{
			return default_value
		}
	}
	
	GetComment(value_name, section_name = "")
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		default_value := Trim(default_value)
		
		if !value_name
		{
			Throw, "Value name can't be empty."
		}

		if (!this.ini_data.HasValue(value_name, section_name))
		{
			return ""
		}
		
		return this.ini_data.GetCommentValue(value_name, section_name)
	}
	
	Set(value_name, section_name, value, comment = "")
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		value := Trim(value)
		comment := Trim(comment)
		
		if (!value_name)
		{
			Throw, "Value name can't be empty."
		}

		this.ini_data.SetValue(value_name, value, section_name)
		
		if (comment)
		{
			this.ini_data.SetCommentValue(value_name, section_name, comment)
		}
	}
	
	SetComment(value_name, section_name, comment)
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		comment := Trim(comment)
		
		if (!value_name)
		{
			Throw, "Value name can't be empty."
		}
		
		if (comment)
		{
			this.ini_data.SetCommentValue(value_name, section_name, comment)
		}
	}
	
	Delete(value_name, section_name)
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		
		if (value_name)
		{
			this.ini_data.DeleteValue(value_name, section_name)
		}
		else
		{
			this.DeleteSection(section_name)
		}
	}
	
	DeleteComment(value_name, section_name)
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		
		if !value_name
		{
			Throw, "Value name can't be empty."
		}
		
		this.ini_data.SetCommentValue(value_name, section_name, "")
	}

	DeleteSection(section_name)
	{
		section_name := Trim(section_name)
		
		this.ini_data.DeleteSection(section_name)
	}

	Exists(value_name, section_name)
	{
		value_name := Trim(value_name)
		section_name := Trim(section_name)
		
		return this.ini_data.HasValue(value_name, section_name)
	}

	ExistsSection(section_name)
	{
		section_name := Trim(section_name)
		
		return this.ini_data.HasSection(section_name)
	}

	Sections()
	{
		return this.ini_data.ListSections()
	}


	class IniData {
		data := {}

		__New(ini_file = "")
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
			if (!this.HasSection(section_name))
			{
				this.CreateSection(section_name)
			}
			
			if (!this.data[section_name].HasKey(value_name))
			{
				this.data[section_name][value_name] := {"value": value, "comment": ""}
			}
			else
			{
				this.data[section_name][value_name].value := value
			}
		}

		GetValue(value_name, section_name)
		{
			return this.GetValueObj(value_name, section_name).value
		}

		GetValueObj(value_name, section_name)
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
		
		
		HasCommentValue(value_name, section_name)
		{
			if !this.HasValue(value_name, section_name)
			{
				return False
			}
			
			return this.data[section_name][value_name].comment != ""
		}
		
		GetCommentValue(value_name, section_name)
		{
			if !this.HasValue(value_name, section_name)
			{
				return ""
			}
			
			return this.data[section_name][value_name].comment
		}
		
		SetCommentValue(value_name, section_name, comment)
		{
			if !this.HasValue(value_name, section_name)
			{
				return False
			}
			
			this.data[section_name][value_name].comment := comment
		}
	}

	class IniParser {
		Parse(ini_file)
		{
			data := {}
			section_name := ""

			Loop, read, %ini_file%
			{
				; lines can be nothing but whitespace
				; we clean them up before processing any further
				line := Trim(A_LoopReadLine)
				
				if !line ; empty line - must ignore
				{
					Continue
				}

				parsed_line := InI.IniParser.ParseLine(line, section_name)

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
				; read Parse(ini_file)
				line := Trim(A_LoopField)
				
				if !line ; empty line - must ignore
				{
					Continue
				}

				parsed_line := InI.IniParser.ParseLine(line, section_name)

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
			
			data[parsed_line.name] := {"value": parsed_line.value, "comment": parsed_line.comment}
			return data
		}

		ParseLine(ini_line, current_section_name)
		{
			char := SubStr(ini_line, 1, 1) ; WHAT THE FUCK? START INDEX AT 1?????
			
			; section identified - needs () because fuck you, that's why
			if (char == "[")
			{
				return InI.IniParser.ParseSection(ini_line)
			}
			; comment identified - handle adding it to the section or next value
			else if (char == "`;")
			{
				; TODO: implement proper comment handling
				return InI.IniParser.ParseComment(ini_line)
			}
			; otherwise, must be a value
			else
			{
				value_data := InI.IniParser.ParseValue(ini_line)
				
				if (value_data)
				{
					value_data.section := current_section_name
				}
				
				return value_data
			}
		}

		ParseSection(line)
		{
			section_data := {"section": "", "name": "", "value": "", "comment": ""}
			
			; ... you need to escape the ; because it will parse as a comment otherwise
			line_data := StrSplit(line, "`;", " `t", 2)
			
			; goal - trim the [] from the line
			section_data.section := Trim(line_data[1], " `t[]")
			
			; if a comment exists, add it to the data
			if (line_data[2])
			{
				comment := InI.IniParser.ParseComment(line_data[2])
				if (comment.comment)
				{
					section_data.comment := comment.comment
				}
			}
			
			return section_data
		}

		ParseValue(line)
		{
			value_data := {"section": "", "name": "", "value": "", "comment": ""}
			
			line_data := StrSplit(line, "`;", " `t", 2)
			
			; only want to split once, to preserve any values
			values := StrSplit(line_data[1], "=", " `t", 2)
			value_data.name := values[1]
			value_data.value := values[2]
			
			; if a comment exists, add it to the data
			if (line_data[2])
			{
				value_data.comment := Trim(line_data[2], " `t")
			}
			
			
			return value_data
		}

		ParseComment(line)
		{
			return {"section": "", "name": "", "value": "", "comment": LTrim(line, "; `t")}
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

					section_data := ini_data.GetSection(section_name)
					if section_data
					{
						line := "[" . section_name . "]`r`n" . InI.IniWriter.MakeValues(section_data) . "`r`n"
						
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
				line := key . " = "  . (value.value)
				
				if (value.comment)
				{
					line .= " `; " . value.comment
				}
				
				ini_text .= line . "`r`n"
			}

			return ini_text
		}
	}
}
