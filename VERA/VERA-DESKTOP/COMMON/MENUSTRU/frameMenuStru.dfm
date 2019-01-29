inherited MenuStruFrame: TMenuStruFrame
  inherited Panel1: TPanel
    OnEnter = Panel1Enter
    inherited DBGridEhVkDoc: TDBGridEhVk
      Width = 135
      Align = alLeft
      Visible = False
    end
    object PanelMenuTree: TPanel
      Left = 136
      Top = 37
      Width = 477
      Height = 189
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object PanelMenuFooter: TPanel
        Left = 0
        Top = 148
        Width = 477
        Height = 41
        Align = alBottom
        Caption = 'PanelMenuFooter'
        TabOrder = 0
        Visible = False
      end
      object vstMenu: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 477
        Height = 148
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.MainColumn = -1
        PopupMenu = PopupMenu1
        TabOrder = 1
        OnChange = vstMenuChange
        OnDragAllowed = vstMenuDragAllowed
        OnDragOver = vstMenuDragOver
        OnDragDrop = vstMenuDragDrop
        OnGetText = vstMenuGetText
        OnInitChildren = vstMenuInitChildren
        OnInitNode = vstMenuInitNode
        Columns = <>
      end
    end
  end
  inherited DocActionList: TActionList
    object aDocSubInsert: TAction
      Caption = #1056#1072#1079#1074#1077#1090#1074#1080#1090#1100
      OnExecute = aDocSubInsertExecute
    end
  end
end
