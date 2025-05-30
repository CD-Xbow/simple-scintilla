;*** Lexers for Scintilla Editor ***

#SCI_SETLEXER = 4001

Procedure InitPureBasicLexer()
  ScintillaSendMessage(1, #SCI_SETLEXER, #SCLEX_CONTAINER, 0)
  Enumeration
    #STYLES_COMMANDS = 1
    #STYLES_COMMENTS
    #STYLES_LITERALSTRINGS
    #STYLES_NUMBERS
    #STYLES_CONSTANTS
    #STYLES_FUNCTIONS
  EndEnumeration

  GOSCI_SetStyleFont(1, #STYLES_COMMANDS, "", -1, #PB_Font_Bold)
  GOSCI_SetStyleColors(1, #STYLES_COMMANDS, $800000)
  GOSCI_SetStyleFont(1, #STYLES_COMMENTS, "", -1, #PB_Font_Italic)
  GOSCI_SetStyleColors(1, #STYLES_COMMENTS, $006400)
  GOSCI_SetStyleColors(1, #STYLES_LITERALSTRINGS, #Gray)
  GOSCI_SetStyleColors(1, #STYLES_NUMBERS, #Red)
  GOSCI_SetStyleColors(1, #STYLES_CONSTANTS, $2193DE)
  GOSCI_SetStyleColors(1, #STYLES_FUNCTIONS, #Blue)

  GOSCI_AddDelimiter(1, ";", "", #GOSCI_DELIMITTOENDOFLINE, #STYLES_COMMENTS)
  GOSCI_AddDelimiter(1, Chr(34), Chr(34), #GOSCI_DELIMITBETWEEN, #STYLES_LITERALSTRINGS)
  GOSCI_AddDelimiter(1, "#", "", #GOSCI_LEFTDELIMITWITHOUTWHITESPACE, #STYLES_CONSTANTS)
  GOSCI_AddDelimiter(1, "(", "", #GOSCI_RIGHTDELIMITWITHWHITESPACE, #STYLES_FUNCTIONS)
  GOSCI_AddDelimiter(1, ")", "", 0, #STYLES_FUNCTIONS)
  GOSCI_AddKeywords(1, "Debug End If ElseIf Else EndIf For To Next Step Protected ProcedureReturn", #STYLES_COMMANDS)
  
  GOSCI_AddKeywords(1, "Procedure Macro", #STYLES_COMMANDS, #GOSCI_OPENFOLDKEYWORD)
  GOSCI_AddKeywords(1, "EndProcedure EndMacro", #STYLES_COMMANDS, #GOSCI_CLOSEFOLDKEYWORD)

  GOSCI_SetLexerOption(1, #GOSCI_LEXEROPTION_SEPARATORSYMBOLS, @"=+-*/%()[],.")
  GOSCI_SetLexerOption(1, #GOSCI_LEXEROPTION_NUMBERSSTYLEINDEX, #STYLES_NUMBERS)
EndProcedure

Procedure InitHTMLLexer()
  ScintillaSendMessage(1, #SCI_SETLEXER, 4, 0)
  GOSCI_SetStyleFont(1, #STYLE_DEFAULT, "Courier New", 10)
  GOSCI_SetStyleColors(1, #SCE_H_TAG, $0000FF)
  GOSCI_SetStyleColors(1, #SCE_H_ATTRIBUTE, $FF0000)
  GOSCI_SetStyleColors(1, #SCE_H_DOUBLESTRING, $008000)
  GOSCI_SetStyleColors(1, #SCE_H_SINGLESTRING, $008000)
  GOSCI_SetStyleColors(1, #SCE_H_COMMENT, $808080)
EndProcedure

Procedure InitJavaScriptLexer()
  ScintillaSendMessage(1, #SCI_SETLEXER, 3, 0)
  GOSCI_SetStyleFont(1, #STYLE_DEFAULT, "Courier New", 10)
  GOSCI_SetStyleColors(1, #SCE_C_COMMENT, $008000)
  GOSCI_SetStyleColors(1, #SCE_C_COMMENTLINE, $008000)
  GOSCI_SetStyleColors(1, #SCE_C_STRING, $FF0000)
  GOSCI_SetStyleColors(1, #SCE_C_CHARACTER, $FF0000)
  GOSCI_SetStyleColors(1, #SCE_C_WORD, $0000FF)
EndProcedure

Procedure InitPythonLexer()
  ScintillaSendMessage(1, #SCI_SETLEXER, 2, 0)
  GOSCI_SetStyleFont(1, #STYLE_DEFAULT, "Courier New", 10)
  GOSCI_SetStyleColors(1, #SCE_P_COMMENTLINE, $008000)
  GOSCI_SetStyleColors(1, #SCE_P_STRING, $FF0000)
  GOSCI_SetStyleColors(1, #SCE_P_WORD, $0000FF)
  GOSCI_SetStyleColors(1, #SCE_P_TRIPLE, $800080)
  GOSCI_SetStyleColors(1, #SCE_P_TRIPLEDOUBLE, $800080)
EndProcedure

Procedure InitCppLexer()
  ScintillaSendMessage(1, #SCI_SETLEXER, 3, 0)
  GOSCI_SetStyleFont(1, #STYLE_DEFAULT, "Courier New", 10)
  GOSCI_SetStyleColors(1, #SCE_C_COMMENT, $008000)
  GOSCI_SetStyleColors(1, #SCE_C_COMMENTLINE, $008000)
  GOSCI_SetStyleColors(1, #SCE_C_STRING, $FF0000)
  GOSCI_SetStyleColors(1, #SCE_C_CHARACTER, $FF0000)
  GOSCI_SetStyleColors(1, #SCE_C_WORD, $0000FF)
EndProcedure

Procedure ClearLexer()
  ScintillaSendMessage(1, #SCI_SETLEXER, 0, 0)
  GOSCI_SetStyleFont(1, #STYLE_DEFAULT, "Courier New", 10)
  GOSCI_SetStyleColors(1, #STYLE_DEFAULT, $000000)
EndProcedure