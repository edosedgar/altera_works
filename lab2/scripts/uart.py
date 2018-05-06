import serial
import crcmod
import time
import struct
import binascii

crc_fun = crcmod.predefined.mkCrcFun('crc-ccitt-false');
ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=1);
duty_cycle = 0

prefix_dig = b'\x00\x02\x49\x01'
prefix_led = b'\x00\x01\x49\x00'
array   = [0x0000,
           0x000c,
           0x00ca,
           0x0caf,
           0xcafe,
           0xafeb,
           0xfeba,
           0xebab,
           0xbabe,
           0xabe0,
           0xbe00,
           0xe000];
counter = 0;

def print_hex_num(number):
    prefix_temp = prefix_dig + struct.pack(">H", number);
    ser.write(prefix_temp + struct.pack(">H", crc_fun(prefix_temp)));
    ser.read(6);

def print_led(number):
    prefix_temp = prefix_led + struct.pack("B", number%16);
    ser.write(prefix_temp + struct.pack(">H", crc_fun(prefix_temp)));
    ser.readline();

# CAFE BABE
"""while True:
    print_hex_num(array[counter%12]);
    print_led(counter);
    counter = counter + 1;
    time.sleep(1);
"""
# Smooth counter
while True:
    print_hex_num(counter);
    time.sleep(0.01 * (10 - duty_cycle)/10);
    print_hex_num(counter + 1);
    time.sleep(0.01 * duty_cycle/10);
    duty_cycle = duty_cycle + 1;
    if (duty_cycle >= 10):
        counter = counter + 1;
        duty_cycle = 0
        time.sleep(1.5)
ser.close();
