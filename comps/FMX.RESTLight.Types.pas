unit FMX.RESTLight.Types;

{
  author: ZuBy
  http://rzaripov.kz
  2016
}

interface

type
  // authorization response
  TmyAuthToken = record
    token: string;
    user_id: string;
    expires_in: Single;
  end;

  // app settings ( vk / facebook / instagram )
  TmyAppSettings = record
    ID: string;
    Key: string;
    OAuthURL: string;
    RedirectURL: string;
    BaseURL: string;
    Scope: string;
    APIVersion: string;
  end;

  // rest params
  TmyRestParam = record
    Key: string;
    value: string;
    is_file: boolean;
    constructor Create(aKey, aValue: string; aIsFile: boolean);
  end;

implementation

{ TmyRestParam }

constructor TmyRestParam.Create(aKey, aValue: string; aIsFile: boolean);
begin
  Self.Key := aKey;
  Self.value := aValue;
  Self.is_file := aIsFile;
end;

end.
