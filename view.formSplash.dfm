object SplashForm: TSplashForm
  Left = 0
  Top = 0
  Caption = 'Latinator'
  ClientHeight = 66
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 304
    Height = 66
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    ExplicitWidth = 309
    ExplicitHeight = 99
    object FSubHeading: TLabel
      Left = 6
      Top = 35
      Width = 298
      Height = 31
      Margins.Top = 10
      Alignment = taCenter
      AutoSize = False
      Caption = 'FSubHeading'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object FHeading: TLabel
      Left = 6
      Top = 8
      Width = 297
      Height = 15
      Margins.Top = 10
      Alignment = taCenter
      AutoSize = False
      Caption = 'FHeading'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
end
