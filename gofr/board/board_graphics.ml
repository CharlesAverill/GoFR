open Graphics
open Textures

let xdim, ydim = (720, 720)
let board_dim = 19
let _ = open_graph (Printf.sprintf " %dx%d" xdim ydim)
let _ = set_window_title "GoFR Interface"
let board_color = 0xF5F5DC

let point x y =
  (* let round_down n = n / 10 * 10 in
     if round_down x mod 20 = 0 && round_down y mod 20 = 0 then set_color beige
     else set_color black; *)
  set_color white;
  fill_rect x y 2 2

(* let img = Image.file "example_image.png" *)
(* Draw Gameboard *)
let _ =
  let cornerx, cornery = (xdim / board_dim / 2, ydim / board_dim / 2) in
  draw_image (gameboard_720 ()) 0 0;
  set_line_width 2;
  draw_rect cornerx cornery
    (xdim * (board_dim - 1) / board_dim)
    (ydim * (board_dim - 1) / board_dim);
  (* Horizontal lines *)
  for x = 0 to board_dim do
    moveto (cornerx + (x * xdim / board_dim)) cornery;
    lineto
      (cornerx + (x * xdim / board_dim))
      (cornery + (ydim * (board_dim - 1) / board_dim))
  done;
  (* Vertical lines *)
  for y = 0 to board_dim do
    moveto cornerx (cornery + (y * ydim / board_dim));
    lineto
      (cornerx + (xdim * (board_dim - 1) / board_dim))
      (cornery + (y * ydim / board_dim))
  done;
  (* Navigation dots *)
  List.iter
    (fun (x, y) ->
      fill_circle
        (cornerx + (x * xdim / board_dim))
        (cornery + (y * ydim / board_dim))
        8)
    [
      (3, 3);
      (9, 3);
      (15, 3);
      (3, 9);
      (9, 9);
      (15, 9);
      (3, 15);
      (9, 15);
      (15, 15);
    ];
  set_line_width 1

(* let _ =
   for y = (size_y () - 1) / 2 downto 0 do
     for x = 0 to (size_x () - 1) / 2 do
       point (2 * x) (2 * y)
     done
   done *)

let _ = set_color (rgb 0 0 0)
let _ = remember_mode false
let xcursor_offset, ycursor_offset = (0, 0)

let _ =
  try
    let place_counter = ref 0 in
    while true do
      let st = wait_next_event [ Mouse_motion; Button_down; Key_pressed ] in
      synchronize ();
      if st.keypressed then raise Exit;
      if st.button then (
        let sprite_to_place =
          if !place_counter mod 2 = 0 then black_piece_40px
          else white_piece_40px
        in
        place_counter := !place_counter + 1;
        remember_mode true;
        draw_image (sprite_to_place ())
          (st.mouse_x - (piece_width_px / 2))
          (st.mouse_y - (piece_width_px / 2));
        remember_mode false);
      let x = st.mouse_x + xcursor_offset and y = st.mouse_y + ycursor_offset in
      moveto 0 y;
      lineto (x - 25) y;
      moveto 10000 y;
      lineto (x + 25) y;
      moveto x 0;
      lineto x (y - 25);
      moveto x 10000;
      lineto x (y + 25)
    done
  with Exit -> ()
