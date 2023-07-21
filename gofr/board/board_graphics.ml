open Graphics
open Textures
open Board_definitions

let xdim, ydim = (720, 720)
let expanded_xdim = int_of_float (Float.mul (float_of_int xdim) 1.5)
let rxdim, rydim = (expanded_xdim - xdim, ydim)
let text_xmargin, text_ymargin = (5, 5)
let board_dim = 19
let fontsize = 32

let replace_at x y (arr : color array array) (new_value : color) =
  let row_length = Array.length arr.(0) in
  if x >= 0 && x < row_length && y >= 0 && y < Array.length arr then
    let _ = arr.(y).(x) <- new_value in
    arr
  else arr

let dither (img : image) : image =
  let carr = ref (dump_image img) in
  let dither_n = 2 in
  for i = 0 to Array.length !carr do
    for j = 0 to Array.length !carr.(0) do
      if i mod dither_n = 0 && j mod dither_n = 0 then
        carr := replace_at i j !carr transp
      else carr := !carr
    done
  done;
  make_image !carr

let boundary_factor = 3

let cornerxf, corneryf =
  let xdim', ydim', board_dim', boundary_factor' =
    ( float_of_int xdim,
      float_of_int ydim,
      float_of_int board_dim,
      float_of_int boundary_factor )
  in
  ( Float.div (Float.div xdim' board_dim') boundary_factor',
    Float.div (Float.div ydim' board_dim') boundary_factor' )

let cornerx, cornery =
  (int_of_float (Float.round cornerxf), int_of_float (Float.round corneryf))

let pixels_per_board_space =
  float_of_int (xdim - cornerx) /. float_of_int board_dim

let board_coords_to_screen_coords x y =
  ( cornerx + (x * (xdim - (2 * cornerx)) / board_dim),
    cornery + (y * (ydim - (2 * cornery)) / board_dim) )

let screen_coords_to_board_coords x y =
  ( max 0
      (int_of_float
         (Float.round
            (float_of_int (x - cornerx + 6) /. pixels_per_board_space))),
    max 0
      (int_of_float
         (Float.round
            (float_of_int (y - cornery + 6) /. pixels_per_board_space))) )

(* let screen_coords_to_board_coords x y =
   let mode list =
     let rec loop maxelt maxcount elt count = function
       | [] -> if count > maxcount then elt else maxelt
       | x :: xs ->
           if elt = x then loop maxelt maxcount elt (count + 1) xs
           else if count > maxcount then loop elt count x 1 xs
           else loop maxelt maxcount x 1 xs
     in
     match List.sort compare list with
     | [] -> None
     | x :: xs -> Some (loop x 0 x 1 xs)
   in
   let board_dim', xdim', ydim' =
     (float_of_int board_dim, float_of_int xdim, float_of_int ydim)
   in
   let xs, ys = ([ x - 1; x; x + 1 ], [ y - 1; y; y + 1 ]) in
   let f dim corn n =
     int_of_float (Float.round ((float_of_int n +. corn) *. board_dim' /. dim))
   in
   let mx, my =
     (List.map (f xdim' cornerxf) xs, List.map (f ydim' corneryf) ys)
   in
   (Option.get (mode mx), Option.get (mode my)) *)
(* ((x + cornerx) * board_dim / xdim, (y + cornery) * board_dim / ydim) *)

let screen_coords_to_board_screen_coords x y =
  let sx, sy = screen_coords_to_board_coords x y in
  board_coords_to_screen_coords sx sy

let in_bounds x y = 0 <= x && x <= xdim && 0 <= y && y <= ydim

let draw_piece (screen_x, screen_y) sprite_to_place : unit =
  remember_mode true;
  draw_image (sprite_to_place ()) screen_x screen_y;
  remember_mode false

let redraw_board newboard =
  remember_mode false;
  draw_rect 0 0 720 720;
  remember_mode true;
  (* Draw Gameboard *)
  let _ =
    (* Background *)
    draw_image (gameboard_720 ()) 0 0;
    set_line_width 2;
    (* Vertical lines *)
    for x = 0 to board_dim do
      moveto (cornerx + ((x * (xdim - (2 * cornerx)) / board_dim) + 1)) cornery;
      lineto
        (cornerx + ((x * (xdim - (2 * cornerx)) / board_dim) + 1))
        (ydim - cornery)
    done;
    (* Horizontal lines *)
    for y = 0 to board_dim do
      moveto cornerx (cornery + (y * (ydim - (2 * cornery)) / board_dim));
      lineto (xdim - cornerx)
        (cornery + (y * (ydim - (2 * cornery)) / board_dim))
    done;
    (* Navigation dots *)
    List.iter
      (fun (x, y) ->
        let x', y' = board_coords_to_screen_coords x y in
        fill_circle x' y' 8)
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
      ]
  in
  match newboard with
  | _, board ->
      for i = 0 to board_dim do
        for j = 0 to board_dim do
          if board (i, j) <> Nil then
            (* I have no idea what the bug is here with the >= 3 thing *)
            let screenx, screeny = board_coords_to_screen_coords i j in
            draw_piece
              (screenx - (piece_width_px / 2), screeny - (piece_width_px / 2))
              (if board (i, j) = Black then black_piece_40px
               else white_piece_40px)
        done
      done

let init_gui game_board =
  open_graph (Printf.sprintf " %dx%d" expanded_xdim ydim);
  set_window_title "GoFR Interface";

  redraw_board game_board;

  (* Draw Register Bank *)
  let _ =
    draw_rect (xdim + cornerx) cornery
      (expanded_xdim - xdim - (2 * cornerx))
      (ydim - (2 * cornery));
    moveto
      (xdim + cornerx + (2 * text_xmargin))
      (ydim - (3 * cornery) - (2 * text_ymargin));
    set_font
      (Printf.sprintf "-*-fixed-medium-r-semicondensed--%d-*-*-*-*-*-iso8859-1"
         fontsize);
    draw_string "R# Opcode N_Args Args";
    set_line_width 3;
    moveto (xdim + cornerx)
      (ydim - (3 * cornery) - (2 * text_ymargin) - (fontsize / 4));
    lineto
      (expanded_xdim - cornerx - 1)
      (ydim - (3 * cornery) - (2 * text_ymargin) - (fontsize / 4));
    set_line_width 2
  in
  set_line_width 1;
  remember_mode false

let place_and_render screen_x screen_y sprite_to_place board : fboard option =
  let boardx, boardy = screen_coords_to_board_coords screen_x screen_y in
  let _ =
    Printf.printf "Placing at (%d, %d) (%d, %d)\n" boardx boardy screen_x
      screen_y
  in
  match
    place boardx boardy
      (if sprite_to_place == black_piece_40px then Black else White)
      board
  with
  | None, _ -> None
  | Some newboard, capture_count ->
      if capture_count <> 0 then
        let _ = redraw_board newboard in
        Some newboard
      else (
        draw_piece (screen_x, screen_y) sprite_to_place;
        Some newboard)

let draw_loop (board : fboard) : fboard =
  let xcursor_offset, ycursor_offset = (0, 0) in
  let counter = ref 0 in
  let rec recur subboard : fboard =
    let new_board_ref = ref subboard in
    try
      let sprite_to_place =
        if !counter mod 2 = 0 then black_piece_40px else white_piece_40px
      in
      let st = wait_next_event [ Mouse_motion; Button_down; Key_pressed ] in
      synchronize ();
      let snap_x, snap_y =
        let x', y' =
          screen_coords_to_board_screen_coords st.mouse_x st.mouse_y
        in
        (x' - (piece_width_px / 2) + 1, y' - (piece_width_px / 2) + 1)
      in
      if st.keypressed then raise Exit;
      if st.button then (
        let new_board' =
          place_and_render snap_x snap_y sprite_to_place !new_board_ref
        in
        if new_board' <> None then new_board_ref := Option.get new_board';
        counter := !counter + 1);
      let x = st.mouse_x + xcursor_offset and y = st.mouse_y + ycursor_offset in
      let _ =
        if in_bounds st.mouse_x st.mouse_y then (
          set_color red;
          moveto 0 y;
          lineto (x - 25) y;
          moveto xdim y;
          lineto (x + 25) y;
          moveto x 0;
          lineto x (y - 25);
          moveto x ydim;
          lineto x (y + 25);
          set_color black;
          draw_image (dither (sprite_to_place ())) snap_x snap_y)
        else ()
      in
      recur !new_board_ref
    with Exit -> !new_board_ref
  in
  recur board
