; Simple Scintilla
; Version 0.8 - LAST MOSTLY WORKING VERSION
; MIT License
; Implements basic editor functionality.
;  Line Numbers, Syntax Highlighting, Folding, Multiple Lexars 
:  
;  jan25 -  may 25 - got popup menu working(finally), Decoding issue solved,
;  march 25 -Added Insert File, date/time. filename 
;  may 25 - Decoding issue solved
;  FIXED = ;  Recent files are recorded but don't load

;  
; TODO
; Add Change Case Functionality, Insert Comment Functionality, Preview, Custom Tools
;  Print And find not implemented
;

 
XIncludeFile "GoScintilla.pbi"
XIncludeFile "Lexers.pbi"
XIncludeFile "AutoDetectTextEncoding_Trim.pbi"
;- Enumeration

#PopupMenu = 1
#MaxRecentFiles = 10
#MenuNew = 18
#MenuFile = 0
#MenuOpen = 1
#MenuSave = 2
#MenuSaveAs = 3
#MenuClose = 4
#MenuRecentFilesBase = 100
#MenuProperties = 200
#MenuEdit = 10
#MenuUndo = 11
#MenuRedo = 12
#MenuCut = 13
#MenuCopy = 14
#MenuPaste = 15
#MenuSelectAll = 16
#MenuDelete = 17
#MenuFind = 51
#MenuInsert = 20
#MenuDateTime = 21
#MenuFilename = 22
#MenuFileInsert = 23
#MenuView = 30
#MenuRefresh = 33
#MenuCollapse = 31
#MenuExpand = 32
#MenuSyntax = 50
#MenuSyntaxNone = 100
#MenuSyntaxPureBasic = 101
#MenuSyntaxHTML = 102
#MenuSyntaxJavaScript = 103
#MenuSyntaxPython = 104
#MenuSyntaxCpp = 105

#MenuTools = 60
#MenuStrip = 61
#MenuEncode = 62
#MenuStringMaster = 63
#MenuConvert = 64
#MenuApps = 65
#MenuAccesories = 66
#MenuSystemInfo = 67
#MenuPerformance = 68
#MenuControl = 69
#MenuCommand = 70
#MenuMSConfig = 71
#MenuApps = 65
#MenuAccesories = 66
#MenuSystemInfo = 67
#MenuPerformance = 68
#MenuControl = 69
#MenuCommand = 70
#MenuMSConfig = 71 
#MenuIPConfig = 72
#MenuPing = 73
#MenuNetUser = 74
#MenuTraceRoute = 75
#MenuWifi = 76          


#MenuOptions = 84
#MenuFont = 85
#MenuWordWrap = 86
#MenuBackcolor = 87
#MenuHelp = 80
#MenuHelpContents = 81
#MenuHelpLinks = 82
#MenuHelpAbout = 83
#MenuHelpGit = 84

#WindowWidth = 800
#WindowHeight = 600
	#WinFind = 1

#StatusBar = 0
#StatusBarSection_Line = 0
#StatusBarSection_File = 1

Global currentFile$ = ""
Global appPath$ = GetPathPart(ProgramFilename())
Global wordWrapEnabled = #False
Global Dim recentFiles.s(#MaxRecentFiles)
Global g_Format

Declare SaveFileAs()
Declare OpenTextFile()
Declare SaveTextFile(file$)
Declare SaveCurrentFile()
Declare FileInsert()
Declare InsertText(text$)
Declare DateTime()
Declare Filename()
Declare UpdateStatusBar()
Declare ResizeGadgets()
Declare ChangeFont()
Declare ToggleWordWrap()
Declare ReloadCurrentFile()
Declare AddToRecentFiles(file$)
Declare UpdateRecentFilesMenu()
Declare OpenRecentFile(index)
Declare CutText()
Declare CopyText()
Declare PasteText()
Declare SelectAllText()
Declare Undo()
Declare Redo()
Declare DeleteText()
Declare ChangeBackcolor()
Declare ShowAboutDialog()
Declare OpenURL(url$)
Declare ShowFileProperties()
;- Procedures
Procedure.s OpenFileToGadget(FilePath$)
    Protected length, oFile, bytes, *mem, Text$
    oFile = ReadFile(#PB_Any, FilePath$)
    If oFile
        g_Format = ReadStringFormat(oFile)
        length = Lof(oFile)
        *mem = AllocateMemory(length)
        If *mem
            bytes = ReadData(oFile, *mem, length)
            If bytes
                If g_Format = #PB_Ascii
                    g_Format = dte::detectTextEncodingInBuffer(*mem, bytes, 0)
                    If g_Format = #PB_Ascii
                        Text$ = PeekS(*mem, bytes, #PB_Ascii)
                    Else
                        Text$ = PeekS(*mem, bytes, #PB_UTF8)
                    EndIf
                Else
                    Text$ = PeekS(*mem, bytes, g_Format)
                EndIf
            EndIf
            FreeMemory(*mem)
        EndIf
        CloseFile(oFile)
    EndIf
    ProcedureReturn Text$
  EndProcedure
  
  
Procedure NewFile()
   ScintillaSendMessage(1, #SCI_CLEARALL, 0, 0)
   ScintillaSendMessage(1, #SCI_GOTOPOS, 0, 0)
  UpdateStatusBar()
EndProcedure

Procedure OpenTextFile()
  ScintillaSendMessage(1, #SCI_CLEARALL, 0, 0)
  ScintillaSendMessage(1, #SCI_GOTOPOS, 0, 0)
  currentFile$ = OpenFileRequester("Open file", "", "All Files (*.*)|*.*", 0)
  If currentFile$
    text$ = OpenFileToGadget(currentFile$)
    If text$
      InsertText(text$)
      AddToRecentFiles(currentFile$)
      UpdateRecentFilesMenu()
    Else
      MessageRequester("Error", "Failed to read the file.", #PB_MessageRequester_Ok)
    EndIf
  EndIf
  UpdateStatusBar()
EndProcedure

Procedure InsertText(text$)
  textUTF8$ = Space(StringByteLength(text$, #PB_UTF8) + 1)
  PokeS(@textUTF8$, text$, -1, #PB_UTF8)
  ScintillaSendMessage(1, #SCI_REPLACESEL, 0, @textUTF8$)
EndProcedure

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
        AddToRecentFiles(file$)
        UpdateRecentFilesMenu()
      EndIf
      CloseFile(0)
    Else
      MessageRequester("Error", "Failed to open the file.", #PB_MessageRequester_Ok)
    EndIf
  EndIf
EndProcedure

Procedure DateTime()
  dateTime$ = FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", Date())
  InsertText(dateTime$)
EndProcedure

Procedure Filename()
  If currentFile$ <> ""
    InsertText(currentFile$)
  Else
    MessageRequester("Error", "No file is currently open.", #PB_MessageRequester_Ok)
  EndIf
EndProcedure

Procedure SaveTextFile(file$)
  If CreateFile(0, file$)
    fileContentLength = ScintillaSendMessage(1, #SCI_GETTEXTLENGTH, 0, 0) + 1
    fileContent$ = Space(fileContentLength)
    ScintillaSendMessage(1, #SCI_GETTEXT, fileContentLength, @fileContent$)
    WriteString(0, fileContent$, #PB_Unicode)
    CloseFile(0)
  Else
    MessageRequester("Error", "Failed to save the file.", #PB_MessageRequester_Ok)
  EndIf
EndProcedure

Procedure SaveCurrentFile()
  If currentFile$ = ""
    SaveFileAs()
  Else
    SaveTextFile(currentFile$)
  EndIf
EndProcedure

Procedure SaveFileAs()
  file$ = SaveFileRequester("Save file as", "", "HTML Files (*.html)|*.html|JavaScript Files (*.js)|*.js|CSS Files (*.css)|*.css|Text Files (*.txt)|*.txt|All Files (*.*)|*.*", 0)
  If file$
    If GetExtensionPart(file$) = ""
      file$ + ".txt"
    EndIf
    SaveTextFile(file$)
    currentFile$ = file$
    AddToRecentFiles(file$)
    UpdateRecentFilesMenu()
    UpdateStatusBar()
  EndIf
EndProcedure

Procedure ReloadCurrentFile()
  If currentFile$ <> ""
    ScintillaSendMessage(1, #SCI_CLEARALL, 0, 0)
    text$ = OpenFileToGadget(currentFile$)
    If text$
      InsertText(text$)
    Else
      MessageRequester("Error", "Failed to read the file.", #PB_MessageRequester_Ok)
    EndIf
    UpdateStatusBar()
  Else
    MessageRequester("Error", "No file to reload.", #PB_MessageRequester_Ok)
  EndIf
EndProcedure

Procedure UpdateStatusBar()
  lineNumber = ScintillaSendMessage(1, #SCI_LINEFROMPOSITION, ScintillaSendMessage(1, #SCI_GETCURRENTPOS), 0) + 1
  StatusBarText(#StatusBar, #StatusBarSection_Line, "  Line: " + Str(lineNumber))
  StatusBarText(#StatusBar, #StatusBarSection_File, "File: " + currentFile$)
 ; StatusBarText(#StatusBar, #StatusBarSection_Line, "Caps: ")
EndProcedure

Procedure ResizeGadgets()
  ResizeGadget(1, 10, 30, WindowWidth(0) - 20, WindowHeight(0) - 70)
EndProcedure

Procedure ChangeFont()
  If FontRequester("", 10, #PB_FontRequester_Effects)
    fontName$ = SelectedFontName()
    fontSize = SelectedFontSize()
    GOSCI_SetFont(1, fontName$, fontSize)
  EndIf
EndProcedure

Procedure ChangeBackcolor()
  color = ColorRequester(#White)
  If color <> -1
    GOSCI_SetColor(1, #GOSCI_BACKCOLOR, color)
  EndIf
EndProcedure

Procedure ToggleWordWrap()
  If wordWrapEnabled
    ScintillaSendMessage(1, #SCI_SETWRAPMODE, #SC_WRAP_NONE, 0)
    wordWrapEnabled = #False
  Else
    ScintillaSendMessage(1, #SCI_SETWRAPMODE, #SC_WRAP_WORD, 0)
    wordWrapEnabled = #True
  EndIf
EndProcedure

Procedure ChangeSyntax(lexerID)
  Select lexerID
    Case #MenuSyntaxNone
      ClearLexer()
    Case #MenuSyntaxPureBasic
      InitPureBasicLexer()
    Case #MenuSyntaxHTML
      InitHTMLLexer()
    Case #MenuSyntaxJavaScript
      InitJavaScriptLexer()
    Case #MenuSyntaxPython
      InitPythonLexer()
    Case #MenuSyntaxCpp
      InitCppLexer()
  EndSelect
EndProcedure

Procedure AddToRecentFiles(file$)
  For i = 0 To #MaxRecentFiles - 1
    If recentFiles(i) = file$
      ProcedureReturn
    EndIf
  Next
  For i = #MaxRecentFiles - 1 To 1 Step -1
    recentFiles(i) = recentFiles(i - 1)
  Next
  recentFiles(0) = file$
EndProcedure

Procedure UpdateRecentFilesMenu()
  For i = 0 To #MaxRecentFiles - 1
    If recentFiles(i) <> ""
      SetMenuItemText(0, #MenuRecentFilesBase + i, recentFiles(i))
    Else
      SetMenuItemText(0, #MenuRecentFilesBase + i, "-")
    EndIf
  Next
EndProcedure

Procedure OpenRecentFile(index)
   file$ = recentFiles(index)
  If FileSize(file$) > 0
    currentFile$ = file$
    ScintillaSendMessage(1, #SCI_CLEARALL, 0, 0)
    text$ = OpenFileToGadget(currentFile$)
    If text$
      InsertText(text$)
    Else
      MessageRequester("Error", "Failed to read the file.", #PB_MessageRequester_Ok)
    EndIf
    UpdateStatusBar()
  Else
    MessageRequester("Error", "File not found: " + file$, #PB_MessageRequester_Ok)
  EndIf
EndProcedure

Procedure CutText()
  ScintillaSendMessage(1, #SCI_CUT, 0, 0)
EndProcedure

Procedure CopyText()
  ScintillaSendMessage(1, #SCI_COPY, 0, 0)
EndProcedure

Procedure PasteText()
  ScintillaSendMessage(1, #SCI_PASTE, 0, 0)
EndProcedure

Procedure SelectAllText()
  ScintillaSendMessage(1, #SCI_SELECTALL, 0, 0)
EndProcedure

Procedure Undo()
  ScintillaSendMessage(1, #SCI_UNDO, 0, 0)
EndProcedure

Procedure Redo()
  ScintillaSendMessage(1, #SCI_REDO, 0, 0)
EndProcedure

Procedure DeleteText()
  ScintillaSendMessage(1, #SCI_CLEAR, 0, 0)
EndProcedure

Procedure ShowAboutDialog()
  MessageRequester("About", "S I M P L E   S C I N" + #CRLF$ + "Copyright CD Xbow 2025" + #CRLF$ + "MIT Licence" + #CRLF$ + "Peace and goodwill To all.", #PB_MessageRequester_Ok)
EndProcedure

Procedure OpenURL(url$)
  RunProgram("explorer.exe", url$, "")
EndProcedure

Procedure ShowFileProperties()
  If currentFile$ <> ""
    fileInfo$ = "Name: " + GetFilePart(currentFile$) + #CRLF$
    fileInfo$ + "Location: " + GetPathPart(currentFile$) + #CRLF$
    fileInfo$ + "Encoding: UTF-8" + #CRLF$
    fileInfo$ + "Type: " + GetExtensionPart(currentFile$) + #CRLF$
    fileInfo$ + "Size: " + Str(FileSize(currentFile$)) + " bytes" + #CRLF$
    fileContentLength = ScintillaSendMessage(1, #SCI_GETTEXTLENGTH, 0, 0)
    fileContent$ = Space(fileContentLength)
    ScintillaSendMessage(1, #SCI_GETTEXT, fileContentLength, @fileContent$)
  ;  fileInfo$ + "Number of words: " + Str(CountString(fileContent$, " ") + 1) + #CRLF$ ; does not work
    fileInfo$ + "Number of characters: " + Str(Len(fileContent$))
    MessageRequester("File Properties", fileInfo$, #PB_MessageRequester_Ok)
  Else
    MessageRequester("Error", "No file is currently open.", #PB_MessageRequester_Ok)
  EndIf
EndProcedure
;- GUI
If OpenWindow(0, 100, 200, 800, 600, "S I M P L E - S C I N", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget |#PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  RemoveKeyboardShortcut(0, #PB_Shortcut_Tab)

  If CreateMenu(0, WindowID(0))
    MenuTitle("File")
    MenuItem(#MenuNew, "New")
    MenuItem(#MenuOpen, "Open")
    MenuItem(#MenuSave, "Save")
    MenuItem(#MenuSaveAs, "Save As")
    MenuBar()
    MenuItem(#MenuProperties, "Properties")
    
    OpenSubMenu("Recent Files")
    For i = 0 To #MaxRecentFiles - 1
      MenuItem(#MenuRecentFilesBase + i, "-")
    Next
    CloseSubMenu()
    MenuBar()
    MenuItem(#MenuClose, "Close")
    
    MenuTitle("Edit")
    MenuItem(#MenuUndo, "Undo")
    MenuItem(#MenuRedo, "Redo")
    MenuBar()
    MenuItem(#MenuCut, "Cut")
    MenuItem(#MenuCopy, "Copy")
    MenuItem(#MenuPaste, "Paste")
    MenuBar()
    MenuItem(#MenuSelectAll, "Select All")
    MenuItem(#MenuDelete, "Delete")
    MenuBar()
    MenuItem(#MenuFind, "Find")
    
    MenuTitle("Insert")
    MenuItem(#MenuDateTime, "Date/Time")
    MenuItem(#MenuFilename, "Filename")
    MenuItem(#MenuFileInsert, "File")
    
    MenuTitle("View")
    MenuItem(#MenuCollapse, "Collapse")
    MenuItem(#MenuExpand, "Expand")
    MenuBar()
   ; MenuItem(#MenuRefresh, "Preview HTML")
   ; DisableMenuItem(0, #MenuRefresh, #True)
    
    MenuTitle("Syntax")
    MenuItem(#MenuSyntaxNone, "None")
    MenuItem(#MenuSyntaxPureBasic, "PureBasic")
    MenuItem(#MenuSyntaxHTML, "HTML")
    MenuItem(#MenuSyntaxJavaScript, "JavaScript")
    MenuItem(#MenuSyntaxPython, "Python")
    MenuItem(#MenuSyntaxCpp, "C/C++")

    MenuTitle("Tools")
    MenuItem(#MenuStrip, "Strip")
    DisableMenuItem(0, #MenuStrip, #True)
    MenuItem(#MenuEncode, "Encode")
    DisableMenuItem(0, #MenuEncode, #True)

    
    OpenSubMenu("Windows")
    MenuItem(65, "Applications")
    MenuItem(66, "Accesories")
    MenuBar()
    MenuItem(67, "System Information")
    MenuItem(68, "Performance")
    MenuItem(69, "Control Panel")
    MenuItem(70, "Command Prompt")
    MenuItem(71, "MS Config")
    CloseSubMenu() 

   OpenSubMenu("Network")
      MenuItem(72, "IP Config")
      MenuItem(73, "Ping")
      MenuItem(74, "Net User")
      MenuItem(75, "Trace Route")  
      MenuItem(76, "Wifi Profiles")      
      CloseSubMenu()
      
   MenuItem(#MenuStringMaster, "StringMaster")
   MenuItem(#MenuConvert, "File Conversion")
   
   OpenSubMenu("Custom")      
      ;for custom tools
   CloseSubMenu()
    
    MenuTitle("Options")
    MenuItem(#MenuFont, "Font")
    MenuItem(#MenuWordWrap, "Word Wrap")
    MenuItem(#MenuBackcolor, "Backcolor")
    
    MenuTitle("Help")
    MenuItem(#MenuHelpContents, "Contents")
    MenuBar()
    MenuItem(#MenuHelpGit , "GitHub")
    MenuItem(#MenuHelpLinks, "Links")
    MenuBar()
    MenuItem(#MenuHelpAbout, "About")
  EndIf
    
; Create Toolbar
  CreateToolBar(0, WindowID(0))
  
  

; #MenuCut = 13
; #MenuCopy = 14
; #MenuPaste = 15
    ToolBarImageButton(#MenuNew, LoadImage(18, "icons/new.ico"))
    ToolBarImageButton(#MenuOpen, LoadImage(1, "icons/open.ico"))
    ToolBarImageButton(#MenuSave, LoadImage(2, "icons/save.ico"))
;     ToolBarImageButton(4, LoadImage(3, "icons/print.ico"))
   ; ToolBarImageButton(#MenuClose, LoadImage(4, "icons/close.ico"))
    ToolBarSeparator()
    ToolBarImageButton(#MenuCut, LoadImage(5, "icons/cut.ico"))
    ToolBarImageButton(#MenuCopy, LoadImage(6, "icons/copy.ico"))
    ToolBarImageButton(#MenuPaste, LoadImage(7, "icons/paste.ico"))
    ToolBarSeparator()
    ToolBarImageButton(#MenuUndo, LoadImage(8, "icons/undo.ico"))
    ToolBarImageButton(#MenuRedo, LoadImage(9, "icons/redo.ico"))
    ToolBarSeparator()
    ToolBarImageButton(#MenuHelpContents, LoadImage(10, "icons/help.ico"))

  
  GOSCI_Create(1, 10, 30, WindowWidth(0) - 20, WindowHeight(0) - 70, 0, #GOSCI_AUTOSIZELINENUMBERSMARGIN)
  GOSCI_SetAttribute(1, #GOSCI_LINENUMBERAUTOSIZEPADDING, 10)
  GOSCI_SetMarginWidth(1, #GOSCI_MARGINFOLDINGSYMBOLS, 24)
  GOSCI_SetColor(1, #GOSCI_CARETLINEBACKCOLOR, $B4FFFF)
  GOSCI_SetFont(1, "Courier New", 10)
  GOSCI_SetTabs(1, 2)
  ScintillaSendMessage(1, #SCI_SETWRAPMODE, #SC_WRAP_NONE, 0)

  If CreateStatusBar(#StatusBar, WindowID(0))
    AddStatusBarField(100)
    AddStatusBarField(#PB_Ignore)
  ;  AddStatusBarField(100)  ;can't get this to work
    UpdateStatusBar()
 
  EndIf
  
 ;- 	Menu Popup
		If CreatePopupMenu(#PopupMenu)
    MenuItem(#MenuUndo, "Undo")
    MenuItem(#MenuRedo, "Redo")
    MenuBar()
    MenuItem(#MenuCut, "Cut")
    MenuItem(#MenuCopy, "Copy")
    MenuItem(#MenuPaste, "Paste")
		EndIf

  ;- 	Find
 
  	If OpenWindow(#WinFind, 0, 0, 475, 195, "Find & Replace",#PB_Window_SystemMenu | #PB_Window_Tool | #PB_Window_Invisible | #PB_Window_ScreenCentered, WindowID(0))
		EndIf

  InitPureBasicLexer()
  UpdateStatusBar()
  
  Repeat
    eventID = WaitWindowEvent()
    Select eventID
;         
;          Case #PB_Event_Gadget
;       Select EventGadget()
;         Case 18 : ;OpenTextFile()
;         Case 2 : ;SaveTextFile()
;         Case 4 : ;PrintTextFile()
;         Case 5 : Break
;         Case 6 : CutText()
;         Case 7 : CopyText()
;         Case 8 : PasteText()
;         Case 10 : Undo()
;         Case 11 : Redo()
;         Case 21 : RunProgram("help.html")
;       EndSelect
      Case #PB_Event_Gadget
        If EventGadget() = 1
          UpdateStatusBar()
        EndIf
        
        If EventType() = #PB_EventType_RightClick
 										DisplayPopupMenu(#PopupMenu, WindowID(0))
 									EndIf  
 									
      Case #PB_Event_CloseWindow
        Break
        
      Case #PB_Event_SizeWindow
        ResizeGadgets()

      Case #PB_Event_Menu
        Select EventMenu()
          Case #MenuNew
            NewFile()  
          Case #MenuOpen
            OpenTextFile()
          Case #MenuSave
            SaveCurrentFile()
          Case #MenuSaveAs
            SaveFileAs()
          Case #MenuProperties
            ShowFileProperties()
             Case #MenuRecentFilesBase To #MenuRecentFilesBase + #MaxRecentFiles - 1
            OpenRecentFile(EventMenu() - #MenuRecentFilesBase)
          Case #MenuClose
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
          Case #MenuDelete
            DeleteText()
          Case #MenuDateTime
            DateTime()
          Case #MenuFilename
            Filename()
          Case #MenuFileInsert
            FileInsert()
          Case #MenuRefresh
            ReloadCurrentFile()
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

          Case #MenuFont
            ChangeFont()
          Case #MenuWordWrap
            ToggleWordWrap()
          Case #MenuBackcolor
            ChangeBackcolor()
          Case #MenuSyntaxNone
            ChangeSyntax(#MenuSyntaxNone)
          Case #MenuSyntaxPureBasic
            ChangeSyntax(#MenuSyntaxPureBasic)
             Case #MenuSyntaxHTML
            ChangeSyntax(#MenuSyntaxHTML)
          Case #MenuSyntaxJavaScript
            ChangeSyntax(#MenuSyntaxJavaScript)
          Case #MenuSyntaxPython
            ChangeSyntax(#MenuSyntaxPython)
          Case #MenuSyntaxCpp
            ChangeSyntax(#MenuSyntaxCpp)
            
        ;  Case #MenuStrip ; Implement Strip functionality here
         ; Case #MenuEncode ; Implement Encode functionality here
          Case #MenuApps : RunProgram("shell:AppsFolder")
          Case #MenuAccesories : RunProgram("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories")
          Case #MenuSystemInfo : RunProgram("msinfo32")  
          Case #MenuPerformance : RunProgram("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools")
          Case #MenuControl	: RunProgram("Control")
          Case #MenuCommand : RunProgram("cmd")
          Case #MenuMSConfig : RunProgram("msconfig")
          Case #MenuApps : RunProgram("shell:AppsFolder")  
          Case #MenuAccesories : RunProgram("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories")
          Case #MenuSystemInfo : RunProgram("msinfo32")
          Case #MenuPerformance :   RunProgram("perfmon")
          Case #MenuIPConfig : RunProgram("cmd", "/k " + "ipconfig /all", "c:\")	
          Case #MenuPing : Input$ = InputRequester("Ping", "Please enter your !P address", "")
                    If Input$ > "" ;192.168.1.1
                       b$ = "ping " + Input$  
                    RunProgram("cmd", "/k " + b$, "C:\")
                      Else  
                    MessageRequester("Information", a$, 0)
                    EndIf
          Case #MenuNetUser : RunProgram("cmd", "/k " + "net user", "C:\") 
          Case #MenuTraceRoute : Input$ = InputRequester("Trace Route - tracert", "Please enter your !P address", "")
                    If Input$ > ""
                       a$ = "tracert " + Input$  
                    RunProgram("cmd", "/k " + a$, "C:\")
                      Else  
                    MessageRequester("Information", a$, 0)
                  EndIf  
          Case #MenuWifi : RunProgram("cmd", "/k " + "netsh wlan show profiles", "C:\")          
            
          Case #MenuConvert : RunProgram("https://www.freeconvert.com/")  
          Case #MenuStringMaster : RunProgram("https://stringmaster.puter.site/")
          Case #MenuHelpContents : RunProgram("help.html")
          Case #MenuHelpGit : RunProgram("https://github.com/")  
          Case #MenuHelpLinks : RunProgram("links.html")
          Case #MenuHelpAbout : ShowAboutDialog()
        EndSelect 
    EndSelect
  Until eventID = #PB_Event_CloseWindow

  GOSCI_Free(1)
EndIf
           
; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 536
; FirstLine = 497
; Folding = ------
; Markers = 557
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; SharedUCRT
; UseIcon = ss.ico
; Executable = simplesin08.exe