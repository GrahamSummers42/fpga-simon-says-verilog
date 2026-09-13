// random number modulenumbers
// generates essentially random numbers
module randomNum(input mclk, output reg [1:0] out);

// creates 21 bit counter
// saves lowest 2 bits  
    reg [20:0] counter = 21'd0;
    always @(posedge mclk) begin
        counter <= counter + 1;
        out <= counter[1:0];
      end
endmodule

// sequence simulation module
// stores and plays back sequence of numbers
module simulatingSequence(
    input mclk,
    input [1:0] randNum,
    input reset,
    input next,
    input [1:0] checkIndex,
    input play,
    input timerOff,
    output reg [15:0] led,
    output reg [1:0] currentCorrect,
    output reg playCompleted,
    output reg [2:0] length
);

    reg [1:0] seq[0:3];
    reg [3:0] index;
    integer i;
    
// defines different led states
    localparam s_start = 2'd0;
    localparam s_flash_on = 2'd1;
    localparam s_flash_off = 2'd2;
    localparam s_complete = 2'd3;

// defines index being played on leds
    reg [1:0] led_state;
    reg [3:0] playIndex;
    
// reset clears sequence
    always @(posedge mclk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) seq[i] <= 2'd0;
                index <= 0;
                length <= 0;
        end else if(next) begin
// adds new random number if sequence is not full
        if (index < 4) begin 
            seq[index] <= randNum;
            index <= index + 1;
            length <= length + 1;
        end
    end
end 

// prevents from going out of bounds
    always @(*) begin
        if (checkIndex < index)
              currentCorrect = seq[checkIndex];
        else
              currentCorrect = 2'd0;
    end 

           
// sets led state
    always @(posedge mclk) begin
// resets when new sequence is generated
        if (next) begin
            playIndex <= 0;
            playCompleted <= 1'b0;
            led <= 16'b0;
            led_state <= s_start;
        end else if (play) begin
            playCompleted <= 1'b0;
                case (led_state)
// flash led if there is a sequence
                    s_start: begin
                        if (index > 0)
                             led_state <= s_flash_on;
                        else
                    led_state <= s_complete;
            end 
                
// flashes led according to the number value
// once timer completes, goes to flash_off state
// sampled from lab 10
        s_flash_on: begin
            case (seq[playIndex])
                2'b00: led <= 16'h0001;
                2'b01: led <= 16'h0002;
                2'b10: led <= 16'h0004;
                2'b11: led <= 16'h0008;
            endcase
            
// waits for time to finish to turn led off
        if (timerOff) begin
            led <= 16'b0;
            led_state <= s_flash_off;
        end
    end 
// goes to completed state if sequence is full
// if not, increments index and goes to flash_on state
        s_flash_off: begin
            if(timerOff) begin
                if (playIndex == index - 1) begin  
                playIndex <= 0;
                led_state <= s_complete;
            end else begin
                playIndex <= playIndex + 1;
                led_state <= s_flash_on;
            end
        end
    end 
// updates playCompleted and resets led
        s_complete: begin
            playCompleted <= 1'b1;
            led <= 16'b0;
        end
        
        default: begin    
            led_state <= s_start;
            led <= 16'b0;
            end
        endcase
    end else begin
        led <= 16'b0;
        playCompleted <= 1'b0;
        led_state <= s_start;
        end
    end 
endmodule 

// timing module
module timer #(parameter MAX_COUNT = 150_000_00)(input mclk, input enable, output reg done);

    reg [31:0] counter = 32'd0;
    
    always @(posedge mclk) begin
// reset when not enabled
        if (!enable) begin
            counter <= 32'd0;
           done <= 1'b0;
        end else begin
// count until max
    if (counter >= MAX_COUNT) begin
        counter <= 32'd0;
        done <= 1'b1;
    end else begin
        counter <= counter + 1;
        done <= 1'b0;
        end
    end
end
    
endmodule 

// synchronizer module
// sampled from lab 12

module syncN #(parameter N = 1) (input clk, input [N-1:0] in, output reg[N-1:0] out);

      reg [N-1:0] unsafe;

      always @(posedge clk) begin
            unsafe <= in;
            out <= unsafe;
      end
endmodule


// user input module
// recieves users inputs
module userInput(input mclk, input  [3:0]  btn_raw, output reg btnValid, output reg [1:0] btnValue);

    wire [3:0] btnSync;

// syncronizes signals
    syncN #(.N(4)) syncButtons (.clk(mclk), .in(btn_raw), .out(btnSync));

    reg [3:0] prev = 4'b0000;
    
// gets button input
    always @(posedge mclk) begin
        btnValid <= 1'b0;
        
    if (prev == 4'b0000 && btnSync != 4'b0000) begin
         btnValid <= 1'b1;
               
// converts the button to a 2-bit value
        case (btnSync)
            4'b0001: btnValue <= 2'd0;
            4'b0010: btnValue <= 2'd1;
            4'b0100: btnValue <= 2'd2;
            4'b1000: btnValue <= 2'd3;
            default: btnValue <= 2'd0;
        endcase
    end
// updates previous state
        prev <= btnSync;
    end
endmodule 
        
// seven segment display module
// sampled lab 6
module sevenSeg(input [3:0] val, output reg [6:0] seg, output [3:0] an);

// assigns the right digit   
assign an = 4'b1110;

    always @(*) begin
        case (val)
              4'h0: seg = 7'b1000000;
              4'h1: seg = 7'b1111001;
              4'h2: seg = 7'b0100100;
              4'h3: seg = 7'b0110000;
              4'h4: seg = 7'b0011001;
              4'h5: seg = 7'b0010010;
              4'h6: seg = 7'b0000010;
              4'h7: seg = 7'b1111000;
              4'h8: seg = 7'b0000000;
              4'h9: seg = 7'b0010000;
              4'hA: seg = 7'b0001000;
              4'hB: seg = 7'b0000011;
              4'hC: seg = 7'b1000110;
              4'hD: seg = 7'b0100001;
              4'hE: seg = 7'b0000110;
              4'hF: seg = 7'b0001110;
               default: seg = 7'b1000000;
        endcase
    end
endmodule 


// fsm module
// main game logic for simon      
module fsm(
    input        mclk,
    input        reset,
    input        btnValid,
    input  [1:0] btnValue,
    input        timerDone,
    input  [1:0] correctSequenceValue,
    input  [2:0] sequenceLength,
    input        playDone,
    output reg       loadNext,
    output reg       play,
    output reg       resetSequence,
    output reg [1:0] checkIndex,
    output reg [3:0] score,
    output reg        anim_active,
    output reg [15:0] anim_led
);

// define game states
    localparam S_IDLE        = 4'd0;
    localparam S_LOAD        = 4'd1;
    localparam S_PLAY        = 4'd2;
    localparam S_WAIT_INPUT  = 4'd3;
    localparam S_CHECK       = 4'd4;
    localparam S_COMPLETED   = 4'd5;
    localparam S_GAME_OVER   = 4'd6;
// animation states
    localparam S_WIN_ON      = 4'd7;
    localparam S_WIN_OFF     = 4'd8;
    localparam S_LOSE_ON     = 4'd9;
    localparam S_LOSE_OFF    = 4'd10;
    
    reg [3:0] state = S_IDLE;
    reg [3:0] next_state;
    reg [2:0] playerIndex;
    reg [2:0] flashCount;

// sets score to 0
    initial score = 4'd0;

// determines the next state
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: next_state = S_LOAD;
            S_LOAD: next_state = S_PLAY;
            S_PLAY: if (playDone) next_state = S_WAIT_INPUT;
            S_WAIT_INPUT: if (btnValid) next_state = S_CHECK;
// checks for correct input
            S_CHECK: begin
                if (btnValue == correctSequenceValue) begin
                    if (playerIndex == sequenceLength - 1) begin
// goes to S_WIN_ON if sequence is full
                        if (sequenceLength == 4)
                            next_state = S_WIN_ON; 
// goes to S_LOAD  
                        else
                            next_state = S_LOAD;
                    end else begin
                        next_state = S_WAIT_INPUT;
                    end
// wrong inputs go to S_LOSE_ON                                        
                end else begin
                    next_state = S_LOSE_ON;
                end
            end
           
// toggles on and off based on flashCount
            S_WIN_ON:  if (timerDone) next_state = S_WIN_OFF;
            S_WIN_OFF: if (timerDone) begin
                           if (flashCount > 0) next_state = S_WIN_ON;
                           else next_state = S_COMPLETED;
                       end
            S_LOSE_ON:  if (timerDone) next_state = S_LOSE_OFF;
            S_LOSE_OFF: if (timerDone) begin
                            if (flashCount > 0) next_state = S_LOSE_ON;
                            else next_state = S_IDLE; // Restart game
                        end
// waits for sw[0] to be flipped to reset sequence
            S_COMPLETED: next_state = S_COMPLETED;
            S_GAME_OVER: next_state = S_GAME_OVER;
            default: next_state = S_IDLE;
        endcase
    end

// updates state and outputs
    always @(posedge mclk) begin
        if (reset) begin
            state <= S_IDLE;
            playerIndex <= 0;
            checkIndex <= 0;
            loadNext <= 0;
            play <= 0;
            resetSequence <= 1'b1;
            anim_active <= 0;
            anim_led <= 16'b0;
// sets default values
        end else begin
            state <= next_state;
            resetSequence <= 1'b0;
            loadNext <= 1'b0;      
            play <= 1'b0;
            anim_active <= 1'b0;
            anim_led <= 16'b0;
            
            case (state)
                S_IDLE: begin
                    playerIndex <= 0;
                    checkIndex <= 0;
                end

// generates new number
                S_LOAD: begin
                    loadNext <= 1'b1;
                    playerIndex <= 0;
                    checkIndex <= 0;
                end

// enables timer in top module
                S_PLAY: begin
                    play <= 1'b1; 
                end

                S_CHECK: begin
                    if (btnValue == correctSequenceValue) begin
// increments playerIndex and checkIndex if less than 4 inputs have been recieved 
                        if (playerIndex < sequenceLength - 1) begin
                            playerIndex <= playerIndex + 1;
                            checkIndex  <= playerIndex + 1;
// resets indices                            
                        end else begin
                            playerIndex <= 0;
                            checkIndex <= 0;
// increments score if 4 inputs have been recieved 
                            if (sequenceLength == 4) begin
                                score <= score + 1;
                                flashCount <= 3;
                            end
                        end
// resets score, sequence, and indices if input is incorrect
                    end else begin
                        score <= 4'd0;
                        resetSequence <= 1'b1;
                        playerIndex <= 0;
                        checkIndex <= 0;
                        flashCount <= 3; 
                    end
                end
// win animtation 
// turns all leds on and of
                S_WIN_ON: begin
                    anim_active <= 1'b1; 
                    play <= 1'b1;  
                    anim_led <= 16'hFFFF; 
                end
                S_WIN_OFF: begin
                    anim_active <= 1'b1;
                    play <= 1'b1; 
                    anim_led <= 16'h0000;
                    if (timerDone) flashCount <= flashCount - 1;
                end
// lose animation
// altenrates leds on and off 
                S_LOSE_ON: begin
                    anim_active <= 1'b1;
                    play <= 1'b1;
                    anim_led <= 16'hAAAA; // found alternating led yt video https://www.youtube.com/watch?v=mbiiLqUGS2w
                end
                S_LOSE_OFF: begin
                    anim_active <= 1'b1;
                    play <= 1'b1;
                    anim_led <= 16'h0000;
                    if (timerDone) flashCount <= flashCount - 1;
                end
            endcase
        end
    end
endmodule

// top module
module top(
    input         mclk,
    input  [3:0]  btn,
    input  [0:0]  sw,      
    output [15:0] led,
    output [7:0]  D1_seg,  
    output [3:0]  D1_a      
);

// uses wires for outputs
    wire [1:0] randVal;
    wire [1:0] correctVal;
    wire [1:0] btnValue;
    wire       btnValid;
    wire       timerDone;
    wire       loadNext;
    wire       play;
    wire [2:0] sequence_length_fsm;
    wire       playDone;
    wire [1:0] checkIndex;
    wire       reset_sequence_from_fsm;
    wire [3:0] score;
    wire [6:0] segWire;
    wire [3:0] anWire;  
    wire [15:0] anim_led;
    wire        anim_active;
    wire [15:0] seq_led_output;

// randonNum instance
    randomNum R(
        .mclk(mclk),
        .out(randVal)
    );

// timer instance
    timer #(.MAX_COUNT(150_000_00)) T (
        .mclk(mclk),
        .enable(play),
        .done(timerDone)
    );

// userInput instance
    userInput I(
        .mclk(mclk),
        .btn_raw(btn),
        .btnValid(btnValid),
        .btnValue(btnValue)
    );

// simulatingSequence instance
    simulatingSequence S(
        .mclk(mclk),
        .randNum(randVal),
        .next(loadNext),
        .play(play),
        .timerOff(timerDone),
        .checkIndex(checkIndex),
        .currentCorrect(correctVal),
        .led(seq_led_output),
        .playCompleted(playDone),
        .length(sequence_length_fsm),
        .reset(sw[0] | reset_sequence_from_fsm)
    );

// sevenSeg instance
    sevenSeg scoreDisplay(
      .val(score),
      .seg(segWire),
      .an(anWire)
    );

// assigns display outputs
    assign D1_seg = {1'b1, segWire};
    assign D1_a   = anWire;

// fsm instance
    fsm F(
        .mclk(mclk),
        .reset(sw[0]),      
        .btnValid(btnValid),
        .btnValue(btnValue),
        .timerDone(timerDone),
        .correctSequenceValue(correctVal),
        .sequenceLength(sequence_length_fsm),
        .playDone(playDone),
        .loadNext(loadNext),
        .play(play),
        .resetSequence(reset_sequence_from_fsm),
        .checkIndex(checkIndex),
        .score(score),
        .anim_active(anim_active),
        .anim_led(anim_led)
    );

// shows fsm pattern if animation is active
    assign led = (anim_active) ? anim_led : seq_led_output;

endmodule
