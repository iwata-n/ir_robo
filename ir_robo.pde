/*
 * @author Iwata,N
 */

#define BAND         (B00)

#define LOW_SPEED    (50)
#define NORMAL_SPEED (100)
#define TURBO_SPEED  (255)

/** ピン設定 */
#define IR_SENSOR    (2)  /* 赤外線センサ */
#define PWMA         (6)
#define PWMB         (5)
#define AIN1         (4)
#define AIN2         (3)
#define BIN1         (A0) /* 将来、USBホストシールドをつけることを考慮 */
#define BIN2         (A1) /* 将来、USBホストシールドをつけることを考慮 */

#define CTRL_F       (B0001)  /* 前進 */
#define CTRL_B       (B0010)  /* 後退 */
#define CTRL_L       (B0011)  /* ステアリング左 */
#define CTRL_R       (B0100)  /* ステアリング右 */
#define CTRL_TF      (B0101)  /* ターボ＋前進 */
#define CTRL_FL      (B0110)  /* 前進＋ステアリング左 */
#define CTRL_FR      (B0111)  /* 前進＋ステアリング右 */
#define CTRL_TFL     (B1000)  /* ターボ+前進+ステアリング左 */
#define CTRL_TFR     (B1001)  /* ターボ+前進+ステアリング右 */
#define CTRL_BL      (B1010)  /* 後退+ステアリング左 */
#define CTRL_BR      (B1011)  /* 後退+ステアリング右 */
#define CTRL_TB      (B1100)  /* ターボ+後退 */
#define CTRL_TBL     (B1101)  /*  */
#define CTRL_TBR     (B1110)  /*  */
#define CTRL_STOP    (B1111)  /* 停止 */


/**
 * モーター１を回す
 *
 * @param[in] power 出力値(==0:停止 >0:正転 <0:逆転)
 */
void motor1(int power) {
  
  analogWrite(PWMA, abs(power));
  
  if (power > 0) {
    digitalWrite(AIN1, HIGH);
    digitalWrite(AIN2, LOW);
  } else {
    digitalWrite(AIN1, LOW);
    digitalWrite(AIN2, HIGH);
  }
  
}

/**
 * モーター2を回す
 *
 * @param[in] power 出力値(==0:停止 >0:正転 <0:逆転)
 */
void motor2(int power) {
  
  analogWrite(PWMB, abs(power));
  
  if (power > 0) {
    digitalWrite(BIN1, HIGH);
    digitalWrite(BIN2, LOW);
  } else {
    digitalWrite(BIN1, LOW);
    digitalWrite(BIN2, HIGH);
  }
  
}

/**
 * setup
 */
void setup() {
  /* for debug */
  //Serial.begin(115200);
  
  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(BIN1, OUTPUT);
  pinMode(BIN2, OUTPUT);
  pinMode(IR_SENSOR, INPUT);
}

/**
 * loop
 */
void loop() {
  unsigned long duration = 0;
  byte band = 0;
  byte data = 0;

  /* スタートビット検出待ち */
  do {
    duration = pulseIn(IR_SENSOR, LOW);
    if (duration == 0) {
        motor1(0);
        motor2(0);
    }
  } while( 1700 > duration || duration > 2100 );
  
  /* バンドを取得 */
  for(int i=0; i<2; i++) {
    duration = pulseIn(IR_SENSOR, LOW);
    if ( 800 < duration && duration < 1200) {
      band += 1 << (1-i);
    }
  }
  
  /* データを取得 */
  for(int i=0; i<4; i++) {
    duration = pulseIn(IR_SENSOR, LOW);
    if ( 800 < duration && duration < 1200) {
      data += 1 << (3-i);
    }
  }
  
  /** for debug
  Serial.print("BAND:");
  Serial.println(band, DEC);
  Serial.print("DATA:");
  Serial.println(data, DEC);
  Serial.println();
  */
  
  /* バンドが一致する場合のみ動作する */
  if (band == BAND) {
    switch(data) {
      case CTRL_F:
        motor1(NORMAL_SPEED);
        motor2(NORMAL_SPEED);
        break;
        
      case CTRL_B:
        motor1(-NORMAL_SPEED);
        motor2(-NORMAL_SPEED);
        break;
        
      case CTRL_TF:
        motor1(TURBO_SPEED);
        motor2(TURBO_SPEED);
        break;
        
      case CTRL_TB:
        motor1(-TURBO_SPEED);
        motor2(-TURBO_SPEED);
        break;
        
      case CTRL_L:
        motor1(0);
        motor2(NORMAL_SPEED);
        break;
        
      case CTRL_R:
        motor1(NORMAL_SPEED);
        motor2(0);
        break;
      
      case CTRL_FL:
        motor1(LOW_SPEED);
        motor2(NORMAL_SPEED);
        break;
        
      case CTRL_FR:
        motor1(NORMAL_SPEED);
        motor2(LOW_SPEED);
        break;
        
      case CTRL_TFL:
        motor1(NORMAL_SPEED);
        motor2(TURBO_SPEED);
        break;
        
      case CTRL_TFR:
        motor1(TURBO_SPEED);
        motor2(NORMAL_SPEED);
        break;
        
      case CTRL_BL:
        motor1(-LOW_SPEED);
        motor2(-NORMAL_SPEED);
        break;
        
      case CTRL_BR:
        motor1(-NORMAL_SPEED);
        motor2(-LOW_SPEED);
        break;
        
      case CTRL_TBL:
        motor1(-NORMAL_SPEED);
        motor2(-TURBO_SPEED);
        break;
        
      case CTRL_TBR:
        motor1(-TURBO_SPEED);
        motor2(-NORMAL_SPEED);
        break;  
        
      case CTRL_STOP:
      default:
        motor1(0);
        motor2(0);
        break;
    }
  } else {
    /* バンドが一致しない場合は停止 */
    motor1(0);
    motor2(0);
  }
  
}
