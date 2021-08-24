unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uLabyrinthe,
  FMX.Objects, FMX.Layouts, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, System.Math.Vectors,
  FMX.Controls3D, FMX.Objects3D, FMX.Viewport3D, FMX.Types3D,
  FMX.MaterialSources, FMX.Ani, uUtils3D, system.Math;

type
  TMainForm = class(TForm)
    layInfos: TLayout;
    Viewport3D1: TViewport3D;
    dmyNiveau: TDummy;
    lmsMur: TLightMaterialSource;
    gameLoop: TFloatAnimation;
    pSol: TPlane;
    lmsSol: TLightMaterialSource;
    lmsMur2: TLightMaterialSource;
    lmsPlafond: TLightMaterialSource;
    Camera1: TCamera;
    dmyJoueur: TDummy;
    lmsMur3: TLightMaterialSource;
    lmsMur4: TLightMaterialSource;
    lLampe: TLight;
    dmyMurs: TDummy;
    dmyNextPosition: TDummy;
    cArrivee: TCylinder;
    dmyBonus: TDummy;
    cInterrupteur: TCube;
    ColorMaterialSource1: TColorMaterialSource;
    ColorMaterialSource2: TColorMaterialSource;
    ColorMaterialSource3: TColorMaterialSource;
    lblChrono: TLabel;
    lblInfos: TLabel;
    recMessage: TRectangle;
    lblMessage: TLabel;
    btnMessage: TButton;
    layIHMMobile: TLayout;
    back: TRectangle;
    LeftBTN: TRectangle;
    RightBTN: TRectangle;
    aniCourse: TFloatAnimation;
    dmyDirection: TDummy;
    layActions: TLayout;
    forwardBTN: TImage;
    backBTN: TImage;
    TurnLeftBTN: TImage;
    TurnRightBTN: TImage;
    layHautBas: TLayout;
    lmsMur5: TLightMaterialSource;
    procedure gameLoopProcess(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btnMessageClick(Sender: TObject);
    procedure FormTouch(Sender: TObject; const Touches: TTouches; const Action: TTouchAction);
  private
    vitesse, vitesseRotation : single;
    function GetDirection: TPoint3D;
    procedure creerMurs(posX, posY: integer);
    procedure genererContenuLabyrinthe;
    procedure gererCollisionBonus(unObjet: TControl3D);
    procedure gererTouches;
  public
    toucheGauche, toucheDroite, toucheHaut, toucheBas, toucheDecalageGauche, toucheDecalageDroite, arriveeActive : boolean;
    niveau : TLabyrinthe;
    heureDebut : TDateTime;
    procedure creerNouvellePartie;
  end;

var
  MainForm: TMainForm;

const
  tailleNiveau = 29;
  vitesseMax = 0.08;
  vitesseRotationMax = 3;

implementation

{$R *.fmx}

procedure TMainForm.gameLoopProcess(Sender: TObject);
begin
  lblChrono.text := formatDateTime('nn:ss', now - heureDebut);

  gererTouches;

  if vitesse = 0 then aniCourse.StopAtCurrent
  else begin
    if not(aniCourse.Running) then aniCourse.Start;
  end;

  var collisionMur := collisionDummyChilds(dmyMurs, dmyNextPosition);
  if not(collisionMur.bool) then begin
    lblInfos.text := '';
    dmyJoueur.Position.Point := dmyNextPosition.Position.Point;
    var collisionBonus := collisionDummyChilds(dmyBonus, dmyJoueur);
    if collisionBonus.bool then gererCollisionBonus(collisionBonus.objet);
  end else begin
    lblInfos.text := 'Collision avec ' + collisionMur.objet.Name;
    vitesse := 0;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  layIHMMobile.Visible := false;
  {$IFDEF ANDROID}
    layIHMMobile.Visible := true;
    FullScreen := true;
  {$ENDIF ANDROID}
  creerNouvellePartie;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (keyChar = 'D') or (keyChar = 'd') or (key = 39) then toucheDroite := true;
  if (keyChar = 'Q') or (keyChar = 'q') or (key = 37) then toucheGauche := true;
  if (keyChar = 'Z') or (keyChar = 'z') or (key = 38) then toucheHaut := true;
  if (keyChar = 'S') or (keyChar = 's') or (key = 40) then toucheBas := true;
  if (keyChar = 'A') or (keyChar = 'a') then toucheDecalageGauche := true;
  if (keyChar = 'E') or (keyChar = 'e') then toucheDecalageDroite := true;
  if key = 112 then begin // Si touche F1 petite aide : l'arrivée et l'interrupteur seront plus grands et donc visibles au dessus des murs
    cArrivee.Height := 50;
    cInterrupteur.Height := 50;
  end;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (keyChar = 'D') or (keyChar = 'd') or (key = 39) then begin
    toucheDroite := false;
    vitesseRotation := 0;
  end;
  if (keyChar = 'Q') or (keyChar = 'q') or (key = 37) then begin
    toucheGauche := false;
    vitesseRotation := 0;
  end;
  if (keyChar = 'Z') or (keyChar = 'z') or (key = 38) then begin
    toucheHaut := false;
    vitesse := 0;
  end;
  if (keyChar = 'S') or (keyChar = 's') or (key = 40) then begin
    toucheBas := false;
    vitesse := 0;
  end;
  if (keyChar = 'A') or (keyChar = 'a') then begin
    toucheDecalageGauche := false;
    vitesse := 0;
  end;
  if (keyChar = 'E') or (keyChar = 'e') then begin
    toucheDecalageDroite := false;
    vitesse := 0;
  end;
end;

procedure TMainForm.FormTouch(Sender: TObject; const Touches: TTouches; const Action: TTouchAction);
begin
  if layIHMMobile.Visible then begin // A faire que si l'IHM dédiée au mobile est visible
    for var iTouch : TTouch in Touches do begin
      if (iTouch.Location.X >= LeftBTN.Position.X) and
         (iTouch.Location.X <= (LeftBTN.Position.X + LeftBTN.Width)) and
         (iTouch.Location.Y >= LeftBTN.Position.Y + layIHMMobile.Position.Y) and
         (iTouch.Location.Y <= (LeftBTN.Position.Y + LeftBTN.height) + layIHMMobile.Position.y + layIHMMobile.Height) then begin
           if (action = TTouchAction.Down) or (action = TTouchAction.Move) then toucheGauche := true
           else toucheGauche := false;
         end;

      if (iTouch.Location.X >= RightBTN.Position.X) and
         (iTouch.Location.X <= (RightBTN.Position.X + RightBTN.Width)) and
         (iTouch.Location.Y >= RightBTN.Position.Y + layIHMMobile.Position.Y) and
         (iTouch.Location.Y <= (RightBTN.Position.Y + RightBTN.height) + layIHMMobile.Position.y + layIHMMobile.Height) then begin
           if (action = TTouchAction.Down) or (action = TTouchAction.Move) then toucheDroite := true
           else toucheDroite := false;
         end;

      if (iTouch.Location.X >= forwardBTN.Position.X + layActions.position.X + layHautBas.Position.x) and
         (iTouch.Location.X <= (forwardBTN.Position.X + forwardBTN.Width + layActions.position.X + layHautBas.Position.x)) and
         (iTouch.Location.Y >= forwardBTN.Position.Y + layIHMMobile.Position.Y) and
         (iTouch.Location.Y <= (forwardBTN.Position.Y + forwardBTN.height) + layIHMMobile.Position.y + layIHMMobile.Height) then begin
           if (action = TTouchAction.Down) or (action = TTouchAction.Move) then toucheHaut := true
           else begin
             toucheHaut := false;
             vitesse := 0;
           end;
         end;

      if (iTouch.Location.X >= backBTN.Position.X + layActions.position.X + layHautBas.Position.x) and
         (iTouch.Location.X <= (backBTN.Position.X + backBTN.Width + layActions.position.X + layHautBas.Position.x)) and
         (iTouch.Location.Y >= backBTN.Position.Y + layIHMMobile.Position.Y) and
         (iTouch.Location.Y <= (backBTN.Position.Y + backBTN.height) + layIHMMobile.Position.y + layIHMMobile.Height) then begin
           if (action = TTouchAction.Down) or (action = TTouchAction.Move) then toucheBas := true
           else begin
             toucheBas := false;
             vitesse := 0;
           end;
         end;

      if (iTouch.Location.X >= turnLeftBTN.Position.X + layActions.position.X) and
         (iTouch.Location.X <= (turnLeftBTN.Position.X + turnLeftBTN.Width + layActions.position.X)) and
         (iTouch.Location.Y >= turnLeftBTN.Position.Y + layIHMMobile.Position.Y) and
         (iTouch.Location.Y <= (turnLeftBTN.Position.Y + turnLeftBTN.height) + layIHMMobile.Position.y + layIHMMobile.Height) then begin
           if (action = TTouchAction.Down) or (action = TTouchAction.Move) then toucheDecalageGauche := true
           else begin
             toucheDecalageGauche := false;
             vitesse := 0;
           end;
         end;

      if (iTouch.Location.X >= turnRightBTN.Position.X + layActions.position.X) and
         (iTouch.Location.X <= (turnRightBTN.Position.X + turnRightBTN.Width + layActions.position.X)) and
         (iTouch.Location.Y >= turnRightBTN.Position.Y + layIHMMobile.Position.Y) and
         (iTouch.Location.Y <= (turnRightBTN.Position.Y + turnRightBTN.height) + layIHMMobile.Position.y + layIHMMobile.Height) then begin
           if (action = TTouchAction.Down) or (action = TTouchAction.Move) then toucheDecalageDroite := true
           else begin
             toucheDecalageDroite := false;
             vitesse := 0;
           end;
         end;
    end;
  end;
end;

procedure TMainForm.creerNouvellePartie;
begin
  recMessage.Visible := false;
  niveau := TLabyrinthe.Create(tailleNiveau, tailleNiveau);
  vitesse := 0;
  vitesseRotation := 0;
  arriveeActive := false;
  cArrivee.MaterialSource := ColorMaterialSource3;
  cArrivee.Height := 0.05;
  cInterrupteur.Height := 0.05;
  pSol.Width := tailleNiveau;
  pSol.Height := tailleNiveau;
  pSol.Position.X := -0.5;
  pSol.Position.Z := -0.5;
  niveau.niveauOuverture := 2;
  niveau.genererLabyrinthe(true);
  genererContenuLabyrinthe;
  camera1.Position.Point := Point3D(0,-0.5,-0.6);
  dmyMurs.DeleteChildren;

  for var i := 0 to niveau.tailleX -1 do begin
    for var j := 0 to niveau.tailleY -1 do begin
      case niveau.matrice[i,j] of
        -1: creerMurs(i, j); // Générer un mur
        1 : begin // Position de départ du joueur
              dmyJoueur.Position.X := i - niveau.tailleX * 0.5;
              dmyJoueur.Position.z := j - niveau.tailleY * 0.5;
            end;
        2 : begin // Posisiton de l'arrivée
              cArrivee.position.X := i - niveau.tailleX * 0.5;
              cArrivee.position.Z := j - niveau.tailleY * 0.5;
              cArrivee.position.Y := - cArrivee.Height * 0.5;
            end;
        3 : begin // Position de l'interrupteur
              cInterrupteur.position.X := i - niveau.tailleX * 0.5;
              cInterrupteur.position.Z := j - niveau.tailleY * 0.5;
              cInterrupteur.position.Y := - cInterrupteur.Height * 0.5;
            end;
      end;
    end;
  end;

  heureDebut := now;
  gameLoop.Start;
end;

procedure TMainForm.btnMessageClick(Sender: TObject);
begin
  creerNouvellePartie;
end;

procedure TMainForm.creerMurs(posX, posY : integer);
begin
  var unCube := TCube.Create(nil);
  unCube.Parent := dmyMurs;
  unCube.Name := 'cube' + dmyMurs.ChildrenCount.ToString;
  unCube.Position.Y := -0.5;
  unCube.Width := 1;
  unCube.Height := 1;
  unCube.Depth := 1;
  unCube.Position.X := posX - niveau.tailleX * 0.5;
  unCube.Position.Z := posY - niveau.tailleY * 0.5;
  unCube.TwoSide := true;
  unCube.SubdivisionsDepth := 5;
  unCube.SubdivisionsHeight := 5;
  unCube.SubdivisionsWidth := 5;
  case random(15) mod 7 of
    1: unCube.MaterialSource := lmsMur2;
    2,3 : unCube.MaterialSource := lmsMur;
    4: unCube.MaterialSource := lmsMur4;
    5: unCube.MaterialSource := lmsMur5;
    else unCube.MaterialSource := lmsMur3;
  end;
end;

function TMainForm.GetDirection: TPoint3D;
begin
  result := (dmyDirection.AbsolutePosition - dmyJoueur.AbsolutePosition).Normalize;  // Détermination de l'orientation
end;

procedure TMainForm.genererContenuLabyrinthe;
begin
  var posDepart := false;
  var posArrivee := false;
  var posInterrupteur := false;

  for var i := 0 to niveau.tailleX-1 do begin
    for var j := 0 to niveau.tailleY-1 do begin
      if not(posDepart) then begin
        if (niveau.matrice[i,j] = 0) and (niveau.getNbVoisinsValeur(i, j, 0) >= 3) then begin // On affecte la position de départ au joueur
          niveau.matrice[i,j] := 1;
          posDepart := true;
        end;
      end;
      if not(posArrivee) then begin
        if (niveau.matrice[i,j] = 0) and (niveau.getNbVoisinsValeur(i, j, -1) >= 2) then begin // On affecte la position d'arrivée
          niveau.matrice[i,j] := 2;
          posArrivee := true;
        end;
      end;
      if posDepart and posArrivee then break;
    end;
    if posDepart and posArrivee then break;
  end;

  for var i := niveau.tailleX-1 downto 0 do begin  // On parcourt la matrice du niveau dans l'autre sens pour que l'interrupteur ne soit pas trop prêt de la sortie
    for var j := niveau.tailleY-1 downto 0 do begin
      if not(posInterrupteur) then begin
        if (niveau.matrice[i,j] = 0) and (niveau.getNbVoisinsValeur(i, j, -1) = 3) then begin // On affecte la position de l'interrupteur
          niveau.matrice[i,j] := 3;
          posInterrupteur := true;
          break;
        end;
      end;
    end;
    if posInterrupteur then break;
  end;
end;

procedure TMainForm.gererCollisionBonus(unObjet: TControl3D);
begin
  case unObjet.Tag of
    1: begin  // Collision avec l'arrivée
         if arriveeActive then begin
           gameLoop.Stop;
           aniCourse.StopAtCurrent;
           lblMessage.Text := 'Gagné !!!';
           recMessage.Visible := true;
         end else lblInfos.Text := 'Sortie non activée.';
       end;
    2: begin
         arriveeActive := true;
         cArrivee.MaterialSource := ColorMaterialSource2;
         lblInfos.Text := 'Sortie activée.';
       end;
  end;
end;

procedure TMainForm.gererTouches;
begin
  if toucheDroite or toucheGauche then begin
    if vitesseRotation < vitesseRotationMax then vitesseRotation := vitesseRotation + 0.05;
    if toucheDroite then dmyJoueur.RotationAngle.Y := dmyJoueur.RotationAngle.Y + vitesseRotation
    else dmyJoueur.RotationAngle.Y := dmyJoueur.RotationAngle.Y - vitesseRotation;
  end;
  if toucheHaut or toucheBas or toucheDecalageGauche or toucheDecalageDroite then begin
    if vitesse < vitesseMax then vitesse := vitesse + 0.005;
    if toucheHaut then dmyNextPosition.position.Point := dmyJoueur.position.Point - getDirection * vitesse;
    if toucheBas then dmyNextPosition.position.Point := dmyJoueur.position.Point + getDirection * vitesse;
    if toucheDecalageGauche then dmyNextPosition.position.Point := dmyJoueur.position.Point + getDirection.Rotate(Point3D(0,1,0), Pi * 0.5) * vitesse;
    if toucheDecalageDroite then dmyNextPosition.position.Point := dmyJoueur.position.Point + getDirection.Rotate(Point3D(0,1,0), -Pi * 0.5) * vitesse;
  end;
end;

end.
