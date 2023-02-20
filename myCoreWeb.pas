unit myCoreWeb;

interface

uses
    WebView2;

const
    IID_ICoreWebView2Controller2: TGUID = '{C979903E-D4CA-4228-92EB-47EE3FA96EAB}';

type
    COREWEBVIEW2_COLOR = packed record
        A : BYTE;
        R : BYTE;
        B : BYTE;
        G : BYTE;
    end;
    TCOREWEBVIEW2_COLOR = COREWEBVIEW2_COLOR;
    PCOREWEBVIEW2_COLOR = ^COREWEBVIEW2_COLOR;

  ICoreWebView2Controller2 = interface(ICoreWebView2Controller)
      ['{C979903E-D4CA-4228-92EB-47EE3FA96EAB}']
      function get_DefaultBackgroundColor(backgroundColor : PCOREWEBVIEW2_COLOR) : HRESULT; stdcall;
      function put_DefaultBackgroundColor(backgroundColor : TCOREWEBVIEW2_COLOR) : HRESULT; stdcall;
  end;


implementation

end.
