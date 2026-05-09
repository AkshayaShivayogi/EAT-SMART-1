# ========================================================== 
# EAT-SMART: USER FRIENDLY AI BASED CALORIE COUNTER & NUTRITION TRACKER 
# With Weekly Report, BMI Analysis & Diet Plan 
# ========================================================== 

import math

def calculate_bmr(age, gender, height, weight): 
    if gender == "male": 
        return 10 * weight + 6.25 * height - 5 * age + 5 
    else: 
        return 10 * weight + 6.25 * height - 5 * age - 161 


def calculate_bmi(weight, height): 
    height_m = height / 100 
    return round(weight / (height_m ** 2), 2) 


def show_food_database(food_db): 
    print("\nAvailable Food Items & Calories (per serving):") 
    print("----------------------------------------------") 
    for food, cal in food_db.items(): 
        print(f"{food.title():15} : {cal} kcal") 


def calorie_nutrition_system(): 

    print("\n===================================================") 
    print("   EAT-SMART: AI BASED CALORIE COUNTER & NUTRITION TRACKER") 
    print("===================================================") 
    print("This system helps you track calories, analyze nutrition,") 
    print("and get AI-based diet recommendations.\n") 

    # ================= USER PROFILE ================= 
    name = input("Enter your name: ") 
    age = int(input("Enter your age: ")) 
    gender = input("Gender (Male/Female): ").lower() 
    height = float(input("Height (in cm): ")) 
    weight = float(input("Weight (in kg): ")) 

    print("\nWhat is your health goal?") 
    print("1. Weight Loss") 
    print("2. Weight Gain") 
    print("3. Maintain Weight") 
    goal = input("Choose (1-3): ") 

    print("\nYour daily activity level:") 
    print("1. Low (No regular exercise)") 
    print("2. Moderate (3–5 days/week)") 
    print("3. High (Daily exercise)") 
    activity = input("Choose (1-3): ") 

    # ================= BMI & CALORIE NEED ================= 
    bmi = calculate_bmi(weight, height) 
    bmr = calculate_bmr(age, gender, height, weight) 

    if activity == "1": 
        daily_calories = bmr * 1.2 
    elif activity == "2": 
        daily_calories = bmr * 1.55 
    else: 
        daily_calories = bmr * 1.725 

    print("\n===================================================") 
    print("                HEALTH ANALYSIS") 
    print("===================================================") 
    print(f"Your BMI: {bmi}") 

    if bmi < 18.5: 
        print("BMI Status: Underweight") 
        status = "Underweight"
    elif bmi <= 24.9: 
        print("BMI Status: Normal weight") 
        status = "Normal"
    else: 
        print("BMI Status: Overweight") 
        status = "Overweight"

    print(f"\nRecommended Daily Calories: {int(daily_calories)} kcal") 
    print("This is the energy your body needs daily.\n") 

    # ================= FOOD DATABASE ================= 
    food_db = { 
        "rice": 130, 
        "roti": 100, 
        "dal": 150, 
        "egg": 70, 
        "chicken": 240, 
        "paneer": 265, 
        "vegetables": 50, 
        "fruits": 60, 
        "milk": 120, 
        "nuts": 170, 
        "junk food": 300 
    } 

    show_food_database(food_db) 

    # ================= WEEKLY INPUT ================= 
    weekly_calories = [] 

    print("\n===================================================") 
    print("        ENTER YOUR WEEKLY FOOD INTAKE") 
    print("===================================================") 
    print("Type food name from the list above.") 
    print("Type 'done' when finished for the day.\n") 

    for day in range(1, 8): 
        print(f"--- Day {day} ---") 
        daily_total = 0 
        while True: 
            food = input("Food eaten: ").lower() 
            if food == "done": 
                break 
            if food in food_db: 
                daily_total += food_db[food] 
            else: 
                print("Food not found. Please choose from the list.") 
        weekly_calories.append(daily_total) 

    # ================= WEEKLY REPORT ================= 
    avg_calories = sum(weekly_calories) / 7 

    print("\n===================================================") 
    print("                WEEKLY REPORT") 
    print("===================================================") 

    for i, cal in enumerate(weekly_calories, start=1): 
        print(f"Day {i}: {cal} kcal") 

    print(f"\nAverage Daily Intake: {int(avg_calories)} kcal") 

    # ================= AI ANALYSIS ================= 
    print("\nAI Nutrition Analysis:") 

    if avg_calories > daily_calories + 200: 
        print("• You are consuming more calories than required.") 
        print("• This may lead to weight gain.") 
    elif avg_calories < daily_calories - 200: 
        print("• You are consuming fewer calories than required.") 
        print("• This may cause weakness or weight loss.") 
    else: 
        print("• Your calorie intake is well balanced.") 
        print("• Good job maintaining a healthy routine.") 

    # ================= DIET PLAN ================= 
    print("\n===================================================") 
    print("            AI RECOMMENDED DIET PLAN") 
    print("===================================================") 

    if goal == "1": 
        print("Weight Loss Diet Plan:") 
        print("• Increase vegetables and fruits") 
        print("• Choose dal, eggs, and paneer for protein") 
        print("• Reduce rice and junk food") 
        print("• Drink plenty of water") 

    elif goal == "2": 
        print("Weight Gain Diet Plan:") 
        print("• Eat frequent healthy meals") 
        print("• Include nuts, milk, paneer, and eggs") 
        print("• Increase calorie-dense healthy foods") 
        print("• Combine with strength exercises") 

    else: 
        print("Weight Maintenance Diet Plan:") 
        print("• Balanced intake of carbs, protein, and fats") 
        print("• Avoid excess junk food") 
        print("• Maintain regular meal timing") 

    print("\n---------------------------------------------------") 
    print(f"Thank you, {name}, for using the EAT-SMART AI Nutrition Tracker!") 
    print("---------------------------------------------------") 


if __name__ == "__main__": 
    calorie_nutrition_system()
