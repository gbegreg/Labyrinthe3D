unit uUtils3D;

interface
uses System.Math.Vectors, System.Types,System.Classes, FMX.Objects3D, Math, FMX.Controls3D, FMX.Graphics, FMX.Types3D, System.UITypes, FMX.Effects,
     System.UIConsts, System.SysUtils, System.RTLConsts, FMX.Types, FMX.Ani, FMX.Viewport3D;

type
  TGBECollisionRetour = record
    bool : boolean;
    objet : TControl3D;
  end;

  function SizeOf3D(const unObjet3D: TControl3D): TPoint3D;
  function collisionDummyChilds(aDummy: TDummy; objet3D : TControl3D): TGBECollisionRetour;
  function collisionEntre2Objets(objet1, objet2 : TControl3D): TGBECollisionRetour;

implementation

function SizeOf3D(const unObjet3D: TControl3D): TPoint3D;
begin
  Result :=NullPoint3D;
  if unObjet3D <> nil then
    result := Point3D(unObjet3D.Width, unObjet3D.Height, unObjet3D.Depth );
end;

function collisionDummyChilds(aDummy: TDummy; objet3D : TControl3D): TGBECollisionRetour;
begin
  var resultat : TGBECollisionRetour;
  resultat.bool := false;
  resultat.objet := nil;
  for var obj in aDummy.Children do begin
    if (obj as TControl3D).visible then begin
      resultat := collisionEntre2Objets(objet3D, (obj as TControl3D));
      if resultat.bool then break;
    end;
  end;
  result := resultat;
end;

function collisionEntre2Objets(objet1, objet2 : TControl3D): TGBECollisionRetour;
begin
  result.objet := nil;
  result.bool := false;
  var DistanceEntreObjets := objet1.Position.Point - objet2.Position.Point;
  var distanceMinimum := (SizeOf3D(objet1) + SizeOf3D(objet2)) * 0.5;

  if ((Abs(DistanceEntreObjets.X) < distanceMinimum.X) and (Abs(DistanceEntreObjets.Y) < distanceMinimum.Y) and
     (Abs(DistanceEntreObjets.Z) < distanceMinimum.Z)) then begin
    result.bool := true;
    result.objet := objet2;
  end;
end;

end.
