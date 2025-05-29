on currentFilePath()
    tell application "TARGET_APPLICATION_NAME"
        set windowName to get name of window 1
        set fileName to my extractFilename(windowName)
        set activeDocument to document 1 whose name ends with fileName
        path of activeDocument
    end tell
end currentFilePath

-- AppleScript to extract a generic filename from a window title that follows the pattern:
-- "prefix — Filename" or "prefix — Filename — Edited"

-- Function to extract the filename
on extractFilename(windowName)
	set extractedFilename to ""
	
	-- Define the common delimiter used in the window titles
	set delimiter to " — "
	
	-- Set AppleScript's text item delimiters to split the string
	set AppleScript's text item delimiters to delimiter
	
	-- Split the window title into parts
	set parts to text items of windowName
	
	-- Reset text item delimiters to default to avoid affecting subsequent operations
	set AppleScript's text item delimiters to ""
	
	-- Check if there are enough parts to contain a filename in the expected format
	if (count of parts) is greater than or equal to 2 then
		-- The filename is typically the second part after the first delimiter
		set potentialFilename to item 2 of parts
		
		-- Check if the potential filename ends with " — Edited" and remove it
		if potentialFilename ends with " — Edited" then
			-- Remove the " — Edited" suffix
			set extractedFilename to text 1 thru ((length of potentialFilename) - (length of " — Edited")) of potentialFilename
		else
			-- If no " — Edited" suffix, the potential filename is the actual filename
			set extractedFilename to potentialFilename
		end if
		
		return extractedFilename
	else
		-- If the format doesn't match the expected pattern, return an error message
		error "The window name format does not match. " & windowName
end if
end extractFilename
