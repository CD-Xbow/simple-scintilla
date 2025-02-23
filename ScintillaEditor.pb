;***Scintilla Editor based on GoScintilla v3***
; Syntax highlighting and collapsing/expanding items through code.

XIncludeFile "GoScintilla.pbi"

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  InitScintilla()
CompilerEndIf

; Constants for menu items
#MenuFile = 0
#MenuOpen = 1
#MenuSave = 2
#MenuSaveAs = 3
#MenuClose = 4
#MenuPrint = 5
#MenuEdit = 10
#MenuCut = 11
#MenuCopy = 12
#MenuPaste = 13
#MenuSelectAll = 14
#MenuUndo = 15
#MenuRedo = 16
#MenuInsert = 20
#MenuDateTime = 21
#MenuFilename = 22
#MenuFileInsert = 23
#MenuView = 30
#MenuCollapse = 31
#MenuExpand = 32
#MenuTools = 40
#MenuOptions = 50
#MenuFont = 51
#MenuColors = 52
#MenuSyntax = 53
#MenuCustom = 54
#MenuWordWrap = 55
#MenuHelp = 60

; Window size
#WindowWidth = 800
#WindowHeight = 600

; Status bar sections
#StatusBar = 0
#StatusBarSection_Line = 0
#StatusBarSection_File = 1

; Variables for file handling
Global currentFile$ = ""
Global appPath$ = GetPathPart(ProgramFilename())
Global wordWrapEnabled = #False

; Forward declare procedures
Declare SaveFileAs()
Declare OpenTextFile()
Declare SaveTextFile(file$)
Declare SaveCurrentFile()
Declare CutText()
Declare CopyText()
Declare PasteText()
Declare SelectAllText()
Declare Undo()
Declare Redo()
Declare DateTime()
Declare Filename()
Declare FileInsert()
Declare InsertText(text$)
Declare UpdateStatusBar()
Declare ResizeGadgets()
Declare ChangeFont()
Declare ChangeBackColor()
Declare ToggleWordWrap()

; Procedure to open a file with proper encoding handling
Procedure OpenTextFile()
  ; Clear the Scintilla gadget
  ScintillaSendMessage(1, #SCI_CLEARALL, 0, 0)
  ; Move the cursor to the top of the page
  ScintillaSendMessage(1, #SCI_GOTOPOS, 0, 0)
  ; Use FileInsert() to select and insert a file
  FileInsert()
  ; Update the status bar with the new file name
  UpdateStatusBar()
EndProcedure

; Procedure to save a file
Procedure SaveTextFile(file$)
  If CreateFile(0, file$)
    fileContentLength = ScintillaSendMessage(1, #SCI_GETTEXTLENGTH, 0, 0) + 1
    fileContent$ = Space(fileContentLength)
    ScintillaSendMessage(1, #SCI_GETTEXT, fileContentLength, @fileContent$)
    WriteString(0, fileContent$, #PB_UTF8)
    CloseFile(0)
  Else
    MessageRequester("Error", "Failed to save the file.", #PB_MessageRequester_Ok)
  EndIf
EndProcedure

; Procedure to save the current file
Procedure SaveCurrentFile()
  If currentFile$ = ""
    SaveFileAs()
  Else
    SaveTextFile(currentFile$)
  EndIf
EndProcedure

; Procedure to save a file as
Procedure SaveFileAs()
  file$ = SaveFileRequester("Save file as", "", "HTML Files (*.html)|*.html|JavaScript Files (*.js)|*.js|CSS Files (*.css)|*.css|Text Files (*.txt)|*.txt|All Files (*.*)|*.*", 0)
  If file$
    ; Ensure the file has the correct extension
    If GetExtensionPart(file$) = ""
      file$ + ".txt"
    EndIf
    SaveTextFile(file$)
    currentFile$ = file$
    ; Update the status bar with the new file name
    UpdateStatusBar()
  EndIf
EndProcedure
Procedure PrintText()
 If currentFile$ = ""
    MessageRequester("Information", "Save file first before you print.", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
  Else
    RunProgram("notepad.exe", "/p " + currentFile$, "")      
        ;  EndIf(currentFile$)
  EndIf
EndProcedure
; Procedure to cut text
Procedure CutText()
  ScintillaSendMessage(1, #SCI_CUT, 0, 0)
EndProcedure

; Procedure to copy text
Procedure CopyText()
  ScintillaSendMessage(1, #SCI_COPY, 0, 0)
EndProcedure

; Procedure to paste text
Procedure PasteText()
  ScintillaSendMessage(1, #SCI_PASTE, 0, 0)
EndProcedure

; Procedure to select all text
Procedure SelectAllText()
  ScintillaSendMessage(1, #SCI_SELECTALL, 0, 0)
EndProcedure

; Procedure to undo
Procedure Undo()
  ScintillaSendMessage(1, #SCI_UNDO, 0, 0)
EndProcedure

; Procedure to redo
Procedure Redo()
  ScintillaSendMessage(1, #SCI_REDO, 0, 0)
EndProcedure

; Procedure to insert text
Procedure InsertText(text$)
  textUTF8$ = Space(StringByteLength(text$, #PB_UTF8) + 1)
  PokeS(@textUTF8$, text$, -1, #PB_UTF8)
  ScintillaSendMessage(1, #SCI_REPLACESEL, 0, @textUTF8$)
EndProcedure

; Procedure to insert date and time
Procedure DateTime()
  dateTime$ = FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", Date())
  InsertText(dateTime$)
EndProcedure

; Procedure to insert filename
Procedure Filename()
  If currentFile$ <> ""
    InsertText(currentFile$)
  Else
    MessageRequester("Error", "No file is currently open.", #PB_MessageRequester_Ok)
  EndIf
EndProcedure

; Procedure to insert a file
Procedure FileInsert()
  file$ = OpenFileRequester("Insert file", "", "All Files (*.*)|*.*", 0)
  If file$
    If ReadFile(0, file$)
      fileSize = Lof(0)
      *buffer = AllocateMemory(fileSize)
      If *buffer
        ReadData(0, *buffer, fileSize)
        fileContent$ = PeekS(*buffer, fileSize, #PB_UTF8)
        FreeMemory(*buffer)
        InsertText(fileContent$)
        currentFile$ = file$
      EndIf
      CloseFile(0)
    Else
      MessageRequester("Error", "Failed to open the file.", #PB_MessageRequester_Ok)
    EndIf
  EndIf
EndProcedure

; Procedure to update the status bar
Procedure UpdateStatusBar()
  lineNumber = ScintillaSendMessage(1, #SCI_LINEFROMPOSITION, ScintillaSendMessage(1, #SCI_GETCURRENTPOS), 0) + 1
  StatusBarText(#StatusBar, #StatusBarSection_Line, "Line: " + Str(lineNumber))
  StatusBarText(#StatusBar, #StatusBarSection_File, "File: " + currentFile$)
EndProcedure

; Procedure to resize gadgets
Procedure ResizeGadgets()
  ResizeGadget(1, 10, 30, WindowWidth(0) - 20, WindowHeight(0) - 70)
EndProcedure

; Procedure to change font
Procedure ChangeFont()
  If FontRequester("", 10, #PB_FontRequester_Effects)
    fontName$ = SelectedFontName()
    fontSize = SelectedFontSize()
    GOSCI_SetFont(1, fontName$, fontSize)
  EndIf
EndProcedure

; Procedure to change background color
Procedure ChangeBackColor()
  color = ColorRequester()
  If color <> -1
    GOSCI_SetColor(1, #GOSCI_BACKCOLOR, color)
  EndIf
EndProcedure

; Procedure to toggle word wrap
Procedure ToggleWordWrap()
  If wordWrapEnabled
    ScintillaSendMessage(1, #SCI_SETWRAPMODE, #SC_WRAP_NONE, 0)
    wordWrapEnabled = #False
  Else
    ScintillaSendMessage(1, #SCI_SETWRAPMODE, #SC_WRAP_WORD, 0)
    wordWrapEnabled = #True
  EndIf
EndProcedure

; GUI -----------------------------------------------------------------------------------
If OpenWindow(0, 100, 200, 800, 600, "PB Lexar", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  RemoveKeyboardShortcut(0, #PB_Shortcut_Tab) ;Required for the tab key to function correctly when the Scintilla control has the focus.
  ; Create the menu
  If CreateMenu(0, WindowID(0))
    MenuTitle("File")
    MenuItem(#MenuOpen, "Open")
    MenuItem(#MenuSave, "Save")
    MenuItem(#MenuSaveAs, "Save As")
    MenuItem(#MenuPrint, "Print")
    MenuItem(#MenuClose, "Close")
   
    MenuTitle("Edit")
    MenuItem(#MenuUndo, "Undo")
    MenuItem(#MenuRedo, "Redo")
    MenuItem(#MenuCut, "Cut")
    MenuItem(#MenuCopy, "Copy")
    MenuItem(#MenuPaste, "Paste")
    MenuItem(#MenuSelectAll, "Select All")
    MenuTitle("Insert")
    MenuItem(#MenuDateTime, "Date/Time")
    MenuItem(#MenuFilename, "Filename")
    MenuItem(#MenuFileInsert, "File") 
    MenuTitle("View")
    MenuItem(#MenuCollapse, "Collapse")
    MenuItem(#MenuExpand, "Expand")  
 ;   MenuTitle("Tools")  
    MenuTitle("Options")
    MenuItem(#MenuFont, "Font")
    MenuItem(#MenuColors, "Colors")
    MenuItem(#MenuSyntax, "Syntax")
    MenuItem(#MenuCustom, "Custom")
    MenuItem(#MenuWordWrap, "Word Wrap") 
    MenuTitle("Help")
  EndIf 
  ; Create the Scintilla gadget
  GOSCI_Create(1, 10, 30, WindowWidth(0) - 20, WindowHeight(0) - 70, 0, #GOSCI_AUTOSIZELINENUMBERSMARGIN)
  GOSCI_SetAttribute(1, #GOSCI_LINENUMBERAUTOSIZEPADDING, 10)
  GOSCI_SetMarginWidth(1, #GOSCI_MARGINFOLDINGSYMBOLS, 24)
  GOSCI_SetColor(1, #GOSCI_CARETLINEBACKCOLOR, $B4FFFF)
  GOSCI_SetFont(1, "Courier New", 10)
  GOSCI_SetTabs(1, 2)
  ScintillaSendMessage(1, #SCI_SETWRAPMODE, #SC_WRAP_NONE, 0)
  ; Create the status bar
  If CreateStatusBar(#StatusBar, WindowID(0))
    AddStatusBarField(100) ; Line number section
    AddStatusBarField(#PB_Ignore) ; File name section
    UpdateStatusBar()
  EndIf
  ; Set styles for syntax highlighting
  Enumeration
    #STYLES_COMMANDS = 1
    #STYLES_COMMENTS
    #STYLES_LITERALSTRINGS
    #STYLES_NUMBERS
    #STYLES_CONSTANTS
    #STYLES_FUNCTIONS
  EndEnumeration

  ; Set individual styles
  GOSCI_SetStyleFont(1, #STYLES_COMMANDS, "", -1, #PB_Font_Bold)
  GOSCI_SetStyleColors(1, #STYLES_COMMANDS, $800000)
  GOSCI_SetStyleFont(1, #STYLES_COMMENTS, "", -1, #PB_Font_Italic)
  GOSCI_SetStyleColors(1, #STYLES_COMMENTS, $006400)
  GOSCI_SetStyleColors(1, #STYLES_LITERALSTRINGS, #Gray)
  GOSCI_SetStyleColors(1, #STYLES_NUMBERS, #Red)
  GOSCI_SetStyleColors(1, #STYLES_CONSTANTS, $2193DE)
  GOSCI_SetStyleColors(1, #STYLES_FUNCTIONS, #Blue)

  ; Set delimiters and keywords
  GOSCI_AddDelimiter(1, ";", "", #GOSCI_DELIMITTOENDOFLINE, #STYLES_COMMENTS)
  GOSCI_AddDelimiter(1, Chr(34), Chr(34), #GOSCI_DELIMITBETWEEN, #STYLES_LITERALSTRINGS)
  GOSCI_AddDelimiter(1, "#", "", #GOSCI_LEFTDELIMITWITHOUTWHITESPACE, #STYLES_CONSTANTS)
  GOSCI_AddDelimiter(1, "(", "", #GOSCI_RIGHTDELIMITWITHWHITESPACE, #STYLES_FUNCTIONS)
  GOSCI_AddDelimiter(1, ")", "", 0, #STYLES_FUNCTIONS)
  GOSCI_AddKeywords(1, "Debug End If ElseIf Else EndIf For To Next Step Protected ProcedureReturn", #STYLES_COMMANDS)
  
  ; Add folding keywords
  GOSCI_AddKeywords(1, "Procedure Macro", #STYLES_COMMANDS, #GOSCI_OPENFOLDKEYWORD)
  GOSCI_AddKeywords(1, "EndProcedure EndMacro", #STYLES_COMMANDS, #GOSCI_CLOSEFOLDKEYWORD)

  ; Additional lexer options
  GOSCI_SetLexerOption(1, #GOSCI_LEXEROPTION_SEPARATORSYMBOLS, @"=+-*/%()[],.")
  GOSCI_SetLexerOption(1, #GOSCI_LEXEROPTION_NUMBERSSTYLEINDEX, #STYLES_NUMBERS)

  ; Update the status bar initially
  UpdateStatusBar()

  ; Main event loop
  Repeat
    eventID = WaitWindowEvent()
    Select eventID
      Case #PB_Event_Gadget
        If EventGadget() = 1
          UpdateStatusBar()
        EndIf
        
      Case #PB_Event_CloseWindow
        Break
        
      Case #PB_Event_SizeWindow
        ResizeGadgets()

      Case #PB_Event_Menu
        Select EventMenu()
          Case #MenuOpen
            OpenTextFile()
          Case #MenuSave
            SaveCurrentFile()
          Case #MenuSaveAs
            SaveFileAs()
          Case #MenuPrint  
            PrintText()
          Case #MenuClose
            ; CloseApplication()
          Case #MenuUndo
            Undo()
          Case #MenuRedo
            Redo()
          Case #MenuCut
            CutText()
          Case #MenuCopy
            CopyText()
          Case #MenuPaste
            PasteText()
          Case #MenuSelectAll
            SelectAllText()
          Case #MenuDateTime
            DateTime()
          Case #MenuFilename
            Filename()
          Case #MenuFileInsert
            FileInsert()
          Case #MenuFont
            ChangeFont()
          Case #MenuColors
            ChangeBackColor()
          Case #MenuWordWrap
            ToggleWordWrap()
          Case #MenuCollapse
            For I = 0 To ScintillaSendMessage(1, #SCI_GETLINECOUNT) - 1
              If ScintillaSendMessage(1, #SCI_GETFOLDLEVEL, I) & #SC_FOLDLEVELHEADERFLAG
                If ScintillaSendMessage(1, #SCI_GETFOLDEXPANDED, I)
                  ScintillaSendMessage(1, #SCI_TOGGLEFOLD, I)
                EndIf
              EndIf
            Next
          Case #MenuExpand
            For I = 0 To ScintillaSendMessage(1, #SCI_GETLINECOUNT) - 1
              If ScintillaSendMessage(1, #SCI_GETFOLDLEVEL, I) & #SC_FOLDLEVELHEADERFLAG
                If ScintillaSendMessage(1, #SCI_GETFOLDEXPANDED, I) = 0
                  ScintillaSendMessage(1, #SCI_TOGGLEFOLD, I)
                EndIf
              EndIf
            Next
        EndSelect 
    EndSelect
  Until eventID = #PB_Event_CloseWindow

  ; Free the Scintilla gadget
  GOSCI_Free(1)
EndIf
; IDE Options = PureBasic 6.20 Beta 1 (Windows - x64)
; CursorPosition = 252
; FirstLine = 248
; Folding = ----
; EnableXP
; DPIAware