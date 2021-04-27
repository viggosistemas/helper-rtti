unit uRTTI;

interface

uses
  {Basics}
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  Vcl.Controls,

  {RTTI}
  RTTI,
  typinfo,

  {Brave}
  Logger,
  uRTTIInterfaces,
  uRTTIAttrib;

type
  TRTTI = class(TInterfacedObject, iKRTTI)
    constructor Create;
    destructor  Destroy; override;
    class function New: iKRTTI;
  strict private

  private
    FRTTIContext: TRttiContext;
    FRTTIType   : TRttiType;
  public
    function ListMethods      (const AObject : TObject                 ): TArray<TRttiMethod>;
    function ListMethodsParams(const AObject: TObject; AMethod: String ): TArray<TRttiParameter>;
    function FindMethods      (const AObject: TObject; AMethod: String ): TRTTIMethod;
    function ExecuteMethods   (const AObject: TObject; const AMethod: string; AParams: TArrayOfValue): TValue;

    function ListObjectFields      ( const AObject: TObject                       ): TArray<TRttiField>;
    function FindObjectFields      ( const AObject: TObject; const AField: String ): TRttiField;
    function FindObjectFieldsValue ( const AObject: TObject; const AField: String ): Variant;
    function FindObject            ( const AObject: TObject; const AField: String ): TObject;
    function FindAttributeSearch   ( const AObject: TObject; const AField: String = '' ): String;

    //function CloneFrom<T: class>(Source: T): T;
    //function Clone(const Parameters:Array of TValue): TObject;
  end;

var
  KRTTI: iKRTTI;

implementation

{ TRTTI }

constructor TRTTI.Create;
begin
  FRTTIContext := TRttiContext.Create;
end;

destructor TRTTI.Destroy;
begin
  FRTTIContext.Free;

  inherited;
end;

class function TRTTI.New: iKRTTI;
begin
  Result := Self.Create;
  KRTTI  := Result;
end;

function TRTTI.FindAttributeSearch( const AObject: TObject; const AField: String = '' ): String;
var
  LRTTIField     : TRttiField;
  LRTTIMethod    : TRttiMethod;
  LRTTIProperty  : TRttiProperty;
  LRTTIAttributes: TCustomAttribute;
begin
  FRTTIType  := FRTTIContext.GetType( TObject( AObject ).ClassType );

  if AField <> '' then
  begin

    LRTTIField := FRTTIType.GetField( AField );

    if LRTTIField <> nil then
    begin
      for LRTTIAttributes in  LRTTIField.GetAttributes do
      begin
        if LRTTIAttributes is Search  then
          Result := Search(LRTTIAttributes).Value;

        if LRTTIAttributes is NumberOnly  then
          Result := Result + Search(LRTTIAttributes).Value + '::::varchar';

        if LRTTIAttributes is DateOnly then
        begin
          Result := 'to_char(' + Result + ', ''DD/MM/YYYY'')'

          //Result := Result + Search(LRTTIAttributes).Value + '::::varchar';
        end;

      end;
    end
    else
      Result := '';

  end
  else
  begin
    for LRTTIField in FRTTIType.GetFields do
    begin
      for LRTTIAttributes in  LRTTIField.GetAttributes do
      begin
        if LRTTIAttributes is Search  then
          Result := Result + Search(LRTTIAttributes).KeyWord + ';';
      end;
    end;
  end;
end;

function TRTTI.FindMethods(const AObject: TObject; AMethod: String): TRTTIMethod;
begin
  FRTTIType := FRTTIContext.GetType( TObject( AObject ).ClassType );

  Result := FRTTIType.GetMethod(AMethod);
end;

function TRTTI.ListMethods(const AObject : TObject): TArray<TRttiMethod>;
var
  LRTTIMethod : TRttiMethod;
begin
  try
    FRTTIType := FRTTIContext.GetType( AObject.ClassType );

    for LRTTIMethod in FRTTIType.GetMethods do
    begin
      //para retornar somente os métodos da classe em questão
      if LRTTIMethod.Parent.Name <> AObject.ClassName then
        Continue;

    end;
  finally
    Result := FRTTIType.GetMethods;
  end;
end;

function TRTTI.ListMethodsParams(const AObject: TObject; AMethod: String): TArray<TRttiParameter>;
var
  LRTTIMethod : TRttiMethod;
  LRRTIParam  : TRttiParameter;
begin
  try
    FRTTIType := FRTTIContext.GetType( AObject.ClassType );

    {Busca o metodo do objeto}
    LRTTIMethod := FindMethods( AObject, AMethod );

    if Assigned(LRTTIMethod) then
    begin
      for LRRTIParam in LRTTIMethod.GetParameters do
      begin


      end;
    end;
  finally
    if Assigned( LRTTIMethod ) then
      Result := LRTTIMethod.GetParameters;
  end;
end;

function TRTTI.ExecuteMethods(const AObject: TObject; const AMethod: string; AParams: TArrayOfValue): TValue;
var
  LRTTIMethod : TRttiMethod;
  LRRTIParam  : TRttiParameter;
  LValue      : TValue;
begin
  FRTTIType := FRTTIContext.GetType( AObject.ClassType );

  try
    {Busca o metodo do objeto}
    LRTTIMethod := FindMethods( AObject, AMethod );

    if Assigned(LRTTIMethod) then
      LValue := LRTTIMethod.Invoke(AObject, AParams);
  finally

  end;
end;

function TRTTI.ListObjectFields(const AObject: TObject): TArray<TRttiField>;
var
  LRTTIField  : TRttiField;
begin
  try
    FRTTIType := FRTTIContext.GetType( AObject.ClassType );

    try
      for LRTTIField in FRTTIType.GetFields do
      begin
        if LRTTIField.GetValue(AObject).IsArray then

        else
        if LRTTIField.GetValue(AObject).IsObject then
             ListObjectFields( LRTTIField.GetValue(AObject).AsObject )
        else

      end;
    except
    end;
  finally
    Result := FRTTIType.GetFields;
  end;
end;

function TRTTI.FindObjectFields( const AObject: TObject; const AField: String       ): TRttiField;
var
  LRTTIField: TRttiField;
  LRTTIMethod: TRttiMethod;
  LRTTIProperty: TRttiProperty;
  LRTTIAttributes: TCustomAttribute;
begin
  FRTTIType := FRTTIContext.GetType( TObject( AObject ).ClassType );

  Result := FRTTIType.GetField(AField);

  if Assigned(Result) then
  begin

  end;
end;

function TRTTI.FindObjectFieldsValue( const AObject : TObject; const AField : String ): Variant;
var
  LRTTIField: TRttiField;
begin
  try
    try
      LRTTIField := FindObjectFields(AObject, AField);

      if Assigned(LRTTIField) then
      begin

      end;
    except
    end;
  finally
    if Assigned(LRTTIField) then
      Result     := LRTTIField.GetValue(AObject).ToString;

  end;
end;

function TRTTI.FindObject(const AObject: TObject; const AField: String): TObject;
var
  LRTTIField: TRttiField;
begin
  try
    try
      LRTTIField := FindObjectFields(AObject, AField);

      if Assigned(LRTTIField) then
      begin
      end;
    except
    end;
  finally
    if Assigned(LRTTIField) then
      Result := LRTTIField.GetValue(AObject).AsObject;

  end;
end;

{
function TRTTI.CloneFrom<T>(Source: T): T;
var
  Context: TRttiContext;
  IsComponent, LookOutForNameProp: Boolean;
  RttiType: TRttiType;
  Method: TRttiMethod;
  MinVisibility: TMemberVisibility;
  Params: TArray<TRttiParameter>;
  Prop: TRttiProperty;
  SourceAsPointer, ResultAsPointer: Pointer;
begin
  RttiType := Context.GetType(Source.ClassType);
  //find a suitable constructor, though treat components specially
  IsComponent := (Source is TComponent);
  for Method in RttiType.GetMethods do
    if Method.IsConstructor then
    begin
      Params := Method.GetParameters;
      if Params = nil then Break;
      if (Length(Params) = 1) and IsComponent and
         (Params[0].ParamType is TRttiInstanceType) and
         SameText(Method.Name, 'Create') then Break;
    end;
  if Params = nil then
    Result := Method.Invoke(Source.ClassType, []).AsType<T>
  else
    Result := Method.Invoke(Source.ClassType, [TComponent(Source).Owner]).AsType<T>;
  try
    //many VCL control properties require the Parent property to be set first
    if Source is TControl then TControl(Result).Parent := TControl(Source).Parent;
    //loop through the props, copying values across for ones that are read/write
    Move(Source, SourceAsPointer, SizeOf(Pointer));
    Move(Result, ResultAsPointer, SizeOf(Pointer));
    LookOutForNameProp := IsComponent and (TComponent(Source).Owner <> nil);
    if IsComponent then
      MinVisibility := mvPublished //an alternative is to build an exception list
    else
      MinVisibility := mvPublic;
    for Prop in RttiType.GetProperties do
      if (Prop.Visibility >= MinVisibility) and Prop.IsReadable and Prop.IsWritable then
        if LookOutForNameProp and (Prop.Name = 'Name') and
          (Prop.PropertyType is TRttiStringType) then
          LookOutForNameProp := False
        else
          Prop.SetValue(ResultAsPointer, Prop.GetValue(SourceAsPointer));
  except
    Result.Free;
    raise;
  end;
end;

function TRTTI.Clone(const Parameters: array of TValue): TObject;
var
  Context: TRttiContext;
  IsComponent, LookOutForNameProp: Boolean;
  RttiType: TRttiType;
  Method: TRttiMethod;
  MinVisibility: TMemberVisibility;
  Params: TArray<TRttiParameter>;
  Prop: TRttiProperty;
  SourceAsPointer, ResultAsPointer: Pointer;
begin
  RttiType := Context.GetType(self.ClassType);

  isComponent := self.InheritsFrom(TComponent);
  for Method in RttiType.GetMethods do
  Begin
    if Method.IsConstructor then
    begin
      Params := Method.GetParameters;
      if Params = nil then Break;
      if (Length(Params) = 1)
      and IsComponent
      and (Params[0].ParamType is TRttiInstanceType)
      and SameText(Method.Name, 'Create') then
      Break;
    end;
  end;

  if Method<>NIL then
    Result := Method.Invoke(self.ClassType, Parameters).AsObject
  else
    Raise Exception.Create('No constructor found error');

  try
    if self.InheritsFrom(TControl) then
    TControl(Result).Parent := TControl(self).Parent;

    Move(self, SourceAsPointer, SizeOf(Pointer));
    Move(Result, ResultAsPointer, SizeOf(Pointer));
    LookOutForNameProp := IsComponent and (TComponent(self).Owner <> nil);
    if IsComponent then
    MinVisibility := mvPublished  else
    MinVisibility := mvPublic;

    for Prop in RttiType.GetProperties do
    begin
      if  (Prop.Visibility >= MinVisibility)
      and Prop.IsReadable and Prop.IsWritable then
      Begin
        if LookOutForNameProp and (Prop.Name = 'Name')
        and (Prop.PropertyType is TRttiStringType) then
        LookOutForNameProp := False else
        Prop.SetValue(ResultAsPointer, Prop.GetValue(SourceAsPointer));
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;
}

end.
