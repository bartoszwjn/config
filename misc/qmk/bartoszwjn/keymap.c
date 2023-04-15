#include QMK_KEYBOARD_H
#include "version.h"

enum layers {
    BASE, // default layer
    CUST, // custom layout
    CUST_FN, // custom layout, second layer
    GAME, // remap some keys for portability
    UTIL, // function keys, mouse input, reset
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
/* Keymap 0: Default layer
 *
 * ,----------------------------------------------------.
 * |   Esc   |   1  |   2  |   3  |   4  |   5  |   -   |
 * |---------+------+------+------+------+--------------|
 * |    `    |   Q  |   W  |   E  |   R  |   T  | =GAME |
 * |---------+------+------+------+------+------|       |
 * |  CapsLk |   A  |   S  |   D  |   F  |   G  |-------|
 * |---------+------+------+------+------+------| ^UTIL |
 * |  LShift |   Z  |   X  |   C  |   V  |   B  |       |
 * `---------+------+------+------+------+--------------'
 *   | LCtrl | PgDn | PgUp | LGui | LAlt |
 *   `-----------------------------------'              ,---------------.
 *                                                      |  Del  |  Ins  |
 *                                              ,-------|-------|-------|
 *                                              |       |       |  Home |
 *                                              | Space | BkSpc |-------|
 *                                              |       |       |  RAlt |
 *                                              `-----------------------'
 *
 *
 *                 ,----------------------------------------------------.
 *                 |   +   |   6  |   7  |   8  |   9  |   0  |  Pause  |
 *                 |-------+------+------+------+------+------+---------|
 *                 | =CUST |   Y  |   U  |   I  |   O  |   P  |    \    |
 *                 |       |------+------+------+------+------+---------|
 *                 |-------|   H  |   J  |   K  |   L  |   ;  |    '    |
 *                 |  RAlt |------+------+------+------+------+---------|
 *                 |       |   N  |   M  |   ,  |   .  |   /  |  RShift |
 *                 `--------------+------+------+------+------+---------'
 *                                | LAlt | RGui |   [  |   ]  | RCtrl |
 * ,---------------.              `-----------------------------------'
 * | ScrLk |PrntScr|
 * |-------+-------+-------.
 * |  End  |       |       |
 * |-------| Enter |  Tab  |
 * |  RAlt |       |       |
 * `-----------------------'
 */
[BASE] = LAYOUT_ergodox(
  // left hand
  KC_ESCAPE   , KC_1      , KC_2    , KC_3    , KC_4    , KC_5 , KC_MINUS ,
  KC_GRAVE    , KC_Q      , KC_W    , KC_E    , KC_R    , KC_T , DF(GAME) ,
  KC_CAPSLOCK , KC_A      , KC_S    , KC_D    , KC_F    , KC_G ,
  KC_LSHIFT   , KC_Z      , KC_X    , KC_C    , KC_V    , KC_B , MO(UTIL) ,
  KC_LCTRL    , KC_PGDOWN , KC_PGUP , KC_LGUI , KC_LALT ,

             KC_DELETE , KC_INSERT ,
                         KC_HOME   ,
  KC_SPACE , KC_BSPACE , KC_RALT   ,

  // right hand
  KC_EQUAL , KC_6 , KC_7    , KC_8     , KC_9        , KC_0        , KC_PAUSE  ,
  DF(CUST) , KC_Y , KC_U    , KC_I     , KC_O        , KC_P        , KC_BSLASH ,
             KC_H , KC_J    , KC_K     , KC_L        , KC_SCOLON   , KC_QUOTE  ,
  KC_RALT  , KC_N , KC_M    , KC_COMMA , KC_DOT      , KC_SLASH    , KC_RSHIFT ,
                    KC_LALT , KC_RGUI  , KC_LBRACKET , KC_RBRACKET , KC_RCTRL  ,

  KC_SLCK  , KC_PSCREEN ,
  KC_END   ,
  KC_RALT  , KC_ENTER   , KC_TAB
),
/* Keymap 1: Custom layout
 *
 * ,----------------------------------------------------.
 * |   Esc   |   1  |   2  |   3  |   4  |   5  |   #   |
 * |---------+------+------+------+------+--------------|
 * |    `    |   Q  |   W  |   E  |   R  |   T  | =GAME |
 * |---------+------+------+------+------+------|       |
 * | ^CUST_FN|   A  |   S  |   D  |   F  |   G  |-------|
 * |---------+------+------+------+------+------| ^UTIL |
 * |  LShift |   Z  |   X  |   C  |   V  |   B  |       |
 * `---------+------+------+------+------+--------------'
 *   | LCtrl | PgDn | PgUp | LGui | LAlt |
 *   `-----------------------------------'              ,---------------.
 *                                                      |  Del  |  Ins  |
 *                                              ,-------|-------|-------|
 *                                              |       |       |  Home |
 *                                              | Space | BkSpc |-------|
 *                                              |       |       |  RAlt |
 *                                              `-----------------------'
 *
 *
 *                 ,----------------------------------------------------.
 *                 |   %   |   6  |   7  |   8  |   9  |   0  |  CapsLk |
 *                 |-------+------+------+------+------+------+---------|
 *                 | =BASE |   Y  |   U  |   I  |   O  |   P  |    \    |
 *                 |       |------+------+------+------+------+---------|
 *                 |-------|   H  |   J  |   K  |   L  |   ;  |    '    |
 *                 |  RAlt |------+------+------+------+------+---------|
 *                 |       |   N  |   M  |   ,  |   .  |   /  |  RShift |
 *                 `--------------+------+------+------+------+---------'
 *                                | LAlt | RGui |   %  |   #  | RCtrl |
 * ,---------------.              `-----------------------------------'
 * | ScrLk |PrntScr|
 * |-------+-------+-------.
 * |  End  |       |       |
 * |-------| Enter |  Tab  |
 * |  RAlt |       |       |
 * `-----------------------'
 */
[CUST] = LAYOUT_ergodox(
  // left hand
  KC_ESCAPE   , KC_1      , KC_2    , KC_3    , KC_4    , KC_5 , KC_HASH  ,
  KC_GRAVE    , KC_Q      , KC_W    , KC_E    , KC_R    , KC_T , DF(GAME) ,
  MO(CUST_FN) , KC_A      , KC_S    , KC_D    , KC_F    , KC_G ,
  KC_LSHIFT   , KC_Z      , KC_X    , KC_C    , KC_V    , KC_B , MO(UTIL) ,
  KC_LCTRL    , KC_PGDOWN , KC_PGUP , KC_LGUI , KC_LALT ,

             KC_DELETE , KC_INSERT ,
                         KC_HOME   ,
  KC_SPACE , KC_BSPACE , KC_RALT   ,

  // right hand
  KC_PERC  , KC_6 , KC_7    , KC_8     , KC_9    , KC_0       , KC_PAUSE  ,
  DF(BASE) , KC_Y , KC_U    , KC_I     , KC_O    , KC_P       , KC_BSLASH ,
             KC_H , KC_J    , KC_K     , KC_L    , KC_SCOLON  , KC_QUOTE  ,
  KC_RALT  , KC_N , KC_M    , KC_COMMA , KC_DOT  , KC_SLASH   , KC_RSHIFT ,
                    KC_LALT , KC_RGUI  , KC_PERC , KC_HASH    , KC_RCTRL  ,

  KC_SLCK  , KC_PSCREEN ,
  KC_END   ,
  KC_RALT  , KC_ENTER   , KC_TAB
),
/* Keymap 2: Custom layout, second layer
 *
 * ,----------------------------------------------------.
 * |         |      |      |      |      |      |       |
 * |---------+------+------+------+------+--------------|
 * |         | Vol+ |      |  Up  |      |      |       |
 * |---------+------+------+------+------+------|       |
 * | _______ | Vol- | Left | Down | Right|      |-------|
 * |---------+------+------+------+------+------|       |
 * | _______ | Mute | Prev | Play | Next |      |       |
 * `---------+------+------+------+------+--------------'
 *   | _____ |      |      | ____ | ____ |
 *   `-----------------------------------'              ,---------------.
 *                                                      |       |       |
 *                                              ,-------|-------|-------|
 *                                              |       |       |       |
 *                                              |   _   |       |-------|
 *                                              |       |       | _____ |
 *                                              `-----------------------'
 *
 *
 *                 ,----------------------------------------------------.
 *                 |       |      |      |      |      |      |         |
 *                 |-------+------+------+------+------+------+---------|
 *                 |       |   *  |   +  |   [  |   ]  |   &  |    %    |
 *                 |       |------+------+------+------+------+---------|
 *                 |-------|   =  |   -  |   (  |   )  |   $  |    #    |
 *                 | _____ |------+------+------+------+------+---------|
 *                 |       |   @  |   ^  |   {  |   }  |   !  | _______ |
 *                 `--------------+------+------+------+------+---------'
 *                                | ____ | ____ |      |      | _____ |
 * ,---------------.              `-----------------------------------'
 * |       |       |
 * |-------+-------+-------.
 * |       |       |       |
 * |-------|       |       |
 * | _____ |       |       |
 * `-----------------------'
 */
[CUST_FN] = LAYOUT_ergodox(
  // left hand
  XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX ,
  XXXXXXX , KC_VOLU , XXXXXXX , KC_UP   , XXXXXXX , XXXXXXX , XXXXXXX ,
  XXXXXXX , KC_VOLD , KC_LEFT , KC_DOWN , KC_RGHT , XXXXXXX ,
  _______ , KC_MUTE , KC_MPRV , KC_MPLY , KC_MNXT , XXXXXXX , XXXXXXX ,
  _______ , XXXXXXX , XXXXXXX , _______ , _______ ,

            XXXXXXX , XXXXXXX ,
                      XXXXXXX ,
  KC_UNDS , XXXXXXX , _______ ,

  // right hand
  XXXXXXX , XXXXXXX  , XXXXXXX  , XXXXXXX , XXXXXXX , XXXXXXX    , XXXXXXX ,
  XXXXXXX , KC_ASTR  , KC_PLUS  , KC_LBRC , KC_RBRC , KC_AMPR    , KC_PERC ,
            KC_EQUAL , KC_MINUS , KC_LPRN , KC_RPRN , KC_DLR     , KC_HASH ,
  _______ , KC_AT    , KC_CIRC  , KC_LCBR , KC_RCBR , KC_EXCLAIM , _______ ,
                       _______  , _______ , XXXXXXX , XXXXXXX    , _______ ,

  XXXXXXX , XXXXXXX ,
  XXXXXXX ,
  _______ , XXXXXXX , XXXXXXX
),
/* Keymap 3: Game layer
 *
 * ,----------------------------------------------------.
 * |   Esc   |   1  |   2  |   3  |   4  |   5  |   -   |
 * |---------+------+------+------+------+--------------|
 * |   Tab   |   Q  |   W  |  Up  |   R  |   T  | =BASE |
 * |---------+------+------+------+------+------|       |
 * |  CapsLk |   A  | Left | Down | Right|   G  |-------|
 * |---------+------+------+------+------+------| ^UTIL |
 * |  LShift |   Z  |   X  |   C  |   V  |   B  |       |
 * `---------+------+------+------+------+--------------'
 *   | LCtrl | PgDn | PgUp | LGui | LAlt |
 *   `-----------------------------------'              ,---------------.
 *                                                      |  Del  |  Ins  |
 *                                              ,-------|-------|-------|
 *                                              |       |       |  Home |
 *                                              | Space | BkSpc |-------|
 *                                              |       |       |  RAlt |
 *                                              `-----------------------'
 *
 *
 *                 ,----------------------------------------------------.
 *                 |   +   |   6  |   7  |   8  |   9  |   0  |  Pause  |
 *                 |-------+------+------+------+------+------+---------|
 *                 | =CUST |   Y  |   U  |   I  |   O  |   P  |    \    |
 *                 |       |------+------+------+------+------+---------|
 *                 |-------|   H  |   J  |   K  |   L  |   E  |    '    |
 *                 |  RAlt |------+------+------+------+------+---------|
 *                 |       |   N  |   M  |   S  |   D  |   F  |  RShift |
 *                 `--------------+------+------+------+------+---------'
 *                                | LAlt | RGui |   [  |   ]  | RCtrl |
 * ,---------------.              `-----------------------------------'
 * | ScrLk |PrntScr|
 * |-------+-------+-------.
 * |  End  |       |       |
 * |-------| Enter |   F1  |
 * |  RAlt |       |       |
 * `-----------------------'
 */
[GAME] = LAYOUT_ergodox(
  // left hand
  KC_ESCAPE   , KC_1      , KC_2    , KC_3    , KC_4    , KC_5 , KC_MINUS ,
  KC_TAB      , KC_Q      , KC_W    , KC_UP   , KC_R    , KC_T , DF(BASE) ,
  KC_CAPSLOCK , KC_A      , KC_LEFT , KC_DOWN , KC_RGHT , KC_G ,
  KC_LSHIFT   , KC_Z      , KC_X    , KC_C    , KC_V    , KC_B , MO(UTIL) ,
  KC_LCTRL    , KC_PGDOWN , KC_PGUP , KC_LGUI , KC_LALT ,

             KC_DELETE , KC_INSERT ,
                         KC_HOME   ,
  KC_SPACE , KC_BSPACE , KC_RALT   ,

  // right hand
  KC_EQUAL , KC_6 , KC_7    , KC_8    , KC_9        , KC_0        , KC_PAUSE  ,
  DF(CUST) , KC_Y , KC_U    , KC_I    , KC_O        , KC_P        , KC_BSLASH ,
             KC_H , KC_J    , KC_K    , KC_L        , KC_E        , KC_QUOTE  ,
  KC_RALT  , KC_N , KC_M    , KC_S    , KC_D        , KC_F        , KC_RSHIFT ,
                    KC_LALT , KC_RGUI , KC_LBRACKET , KC_RBRACKET , KC_RCTRL  ,

  KC_SLCK  , KC_PSCREEN ,
  KC_END   ,
  KC_RALT  , KC_ENTER   , KC_F1
),
/* Keymap 4: Utility layer
 *
 * ,----------------------------------------------------.
 * |         |  F1  |  F2  |  F3  |  F4  |  F5  |  F11  |
 * |---------+------+------+------+------+--------------|
 * |         |      |      |  Up  |      |      |       |
 * |---------+------+------+------+------+------|       |
 * |         |      | Left | Down | Right|      |-------|
 * |---------+------+------+------+------+------| _____ |
 * | _______ |      |      |      |      |      |       |
 * `---------+------+------+------+------+--------------'
 *   | _____ |      |      | ____ | ____ |
 *   `-----------------------------------'              ,---------------.
 *                                                      |       |       |
 *                                              ,-------|-------|-------|
 *                                              |       |       |       |
 *                                              |       |       |-------|
 *                                              |       |       |       |
 *                                              `-----------------------'
 *
 *
 *                 ,----------------------------------------------------.
 *                 |  F12  |  F6  |  F7  |  F8  |  F9  |  F10 |  Reset  |
 *                 |-------+------+------+------+------+------+---------|
 *                 |       |      |      | MsUp |      |MsWhUp|         |
 *                 |       |------+------+------+------+------+---------|
 *                 |-------|      |MsLeft|MsDown|MsRght|MsWhDn|         |
 *                 |       |------+------+------+------+------+---------|
 *                 |       |      |      |      |      |      | _______ |
 *                 `--------------+------+------+------+------+---------'
 *                                | ____ | ____ |      |      | _____ |
 * ,---------------.              `-----------------------------------'
 * |       |  Ms3  |
 * |-------+-------+-------.
 * |  Ms5  |       |       |
 * |-------|  Ms2  |  Ms1  |
 * |  Ms4  |       |       |
 * `-----------------------'
 */
[UTIL] = LAYOUT_ergodox(
  // left hand
  XXXXXXX , KC_F1   , KC_F2   , KC_F3   , KC_F4   , KC_F5   , KC_F11  ,
  XXXXXXX , XXXXXXX , XXXXXXX , KC_UP   , XXXXXXX , XXXXXXX , XXXXXXX ,
  XXXXXXX , XXXXXXX , KC_LEFT , KC_DOWN , KC_RGHT , XXXXXXX ,
  _______ , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , _______ ,
  _______ , XXXXXXX , XXXXXXX , _______ , _______ ,

            XXXXXXX , XXXXXXX ,
                      XXXXXXX ,
  XXXXXXX , XXXXXXX , XXXXXXX ,

  // right hand
  KC_F12  , KC_F6   , KC_F7   , KC_F8   , KC_F9   , KC_F10        , RESET   ,
  XXXXXXX , XXXXXXX , XXXXXXX , KC_MS_U , XXXXXXX , KC_MS_WH_UP   , XXXXXXX ,
            XXXXXXX , KC_MS_L , KC_MS_D , KC_MS_R , KC_MS_WH_DOWN , XXXXXXX ,
  XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX , XXXXXXX       , _______ ,
                      _______ , _______ , XXXXXXX , XXXXXXX       , _______ ,

  XXXXXXX    , KC_MS_BTN3 ,
  KC_MS_BTN5 ,
  KC_MS_BTN4 , KC_MS_BTN2 , KC_MS_BTN1
),
};



bool led_update_user(led_t led_state) {
  if (led_state.caps_lock) {
    ergodox_right_led_2_on();
  } else {
    ergodox_right_led_2_off();
  }

  return true;
}

layer_state_t default_layer_state_set_user(layer_state_t state) {
  if (IS_LAYER_ON_STATE(state, CUST)) {
    ergodox_right_led_3_on();
  } else {
    ergodox_right_led_3_off();
  }

  if (IS_LAYER_ON_STATE(state, GAME)) {
    ergodox_right_led_1_on();
  } else {
    ergodox_right_led_1_off();
  }

  return state;
}
