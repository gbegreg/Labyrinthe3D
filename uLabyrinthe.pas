{ Grégory Bersegeay : génération de labyrinthe via la fusion aléatoire de chemins
  https://fr.wikipedia.org/wiki/Mod%C3%A9lisation_math%C3%A9matique_de_labyrinthe
}

unit uLabyrinthe;

interface
uses system.Classes, System.SysUtils, System.Generics.Collections;

type
  TMur = record
    x,y: integer;
  end;

  TLabyrinthe = class
    tailleX, tailleY, niveauOuverture : integer;
    matrice : array of array of integer;
    listeMurs : TList<TMur>;
  private
    procedure ouvrirLabyrinthe;
    procedure listerMursCassables;
  public
    constructor Create(X, Y: integer); virtual;
    destructor Destroy; override;
    function getNbVoisinsValeur(i, j, valeur : integer):integer;
    procedure genererLabyrinthe(complexe : boolean = false);
  end;

implementation

constructor TLabyrinthe.Create(X, Y: integer);
begin
  tailleX := X;
  tailleY := Y;
  listeMurs := TList<TMur>.create;
end;

destructor TLabyrinthe.Destroy;
begin
  FreeAndNil(listeMurs);
  inherited;
end;

procedure TLabyrinthe.genererLabyrinthe(complexe : boolean = false);
begin
  randomize;
  setlength(matrice, tailleX, tailleY);
  var nb := 0;
  for var i := 0 to tailleX-1 do begin  // Initialisation de la grille
     for var j := 0 to tailleY-1 do begin
       if (i = 0) or (i = tailleX-1) then matrice[i,j] := -1
       else begin
         if (j = 0) or (j = tailleY-1) then matrice[i,j] := -1
         else begin
           if i mod 2 = 0 then matrice[i,j] := -1
           else begin
             if j mod 2 = 0 then matrice[i,j] := -1
             else begin
               matrice[i,j] := nb;
               inc(nb);
             end;
           end;
         end;
       end;
     end;
  end;

  listerMursCassables; // Liste des murs cassables

  while  listeMurs.Count > 0 do begin  // Tant qu'il y a un mur cassable
    var unMur := listeMurs[random(listeMurs.count)];  // On sélectionne un mur cassable au hazard dans la liste
    var x := unMur.x;
    var y := unMur.y;
    var cell1, cell2 : integer;

    if matrice[x -1, y] < 0 then begin  // si la case précédente sur la ligne est un mur
      cell1 := matrice[x, y -1];         // alors on prend en compte la case du dessus
      cell2 := matrice[x, y +1];         // et celle de dessous
    end else begin
      cell1 := matrice[x -1, y];         // sinon, on prend en compte la case de gauche
      cell2 := matrice[x +1, y];         // et la cause de droite
    end;

    if cell1 <> cell2 then begin         // Si les valeurs des deux cases à prendre en compte sont différentes
      matrice[x,y] := cell1;             // on casse le mur en lui affectant la valeur de la cellule 1
      for var i := 1 to tailleX-2 do begin
        for var j := 1 to tailleY-2 do begin
          if matrice[i,j] = cell2 then matrice[i,j] := cell1;  // on remplace dans la grille toutes les cases qui aurait la valeur de la cellule 2 par la valeur de la cellule 1
        end;
      end;
    end;

    listeMurs.Delete(listeMurs.IndexOf(unMur)); // On supprime le mur cassable utilisé
  end;

  for var i := 0 to tailleX-1 do // On remplace tous les nombres >= 0 par 0
    for var j := 0 to tailleY-1 do
      if matrice[i,j] >= 0 then matrice[i,j] := 0;

  if complexe then ouvrirLabyrinthe; // Si on souhaite un labyrinthe complexe (plusieurs chemins possibles, salles)
end;

function TLabyrinthe.getNbVoisinsValeur(i, j, valeur : integer):integer;
begin
  result := 0;
  if matrice[i+1,j] = valeur then inc(result);
  if matrice[i-1,j] = valeur then inc(result);
  if matrice[i,j+1] = valeur then inc(result);
  if matrice[i,j-1] = valeur then inc(result);
end;

procedure TLabyrinthe.ouvrirLabyrinthe;
begin
  for var h := 1 to niveauOuverture do
    for var i := 1 to tailleX-2 do
      for var j := 1 to tailleY-2 do
        if matrice[i,j] = -1 then begin
          if getNbVoisinsValeur(i, j, 0) >= 3 then matrice[i,j] := 0; // On supprime les murs qui ont 3 cellules vides autour d'eux
        end;
end;

procedure TLabyrinthe.listerMursCassables; // liste les murs cassables dans l'aire de jeu
begin
  listeMurs.Clear;
  var mur : TMur;
  for var i := 1 to tailleX-2 do begin
    for var j := 1 to tailleY-2 do begin
      if i mod 2 = 0 then begin   // si i est pair
        if j mod 2 <> 0 then begin // alors j doit être impair pour que le mur soit considéré comme cassable
          mur.x := i;
          mur.y := j;
          listeMurs.Add(mur);
        end;
      end else begin                 // si i est impair
        if j mod 2 = 0 then begin     // alors j doit être pair pour que le mur soit considéré comme cassable
          mur.x := i;
          mur.y := j;
          listeMurs.Add(mur);
        end;
      end;
    end;
  end;
end;

end.
