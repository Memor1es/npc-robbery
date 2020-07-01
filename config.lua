Config = {}
Config.Locale = 'en'

Config.ShouldWaitBetweenRobbing = false
Config.MinWaitSeconds = 60
Config.MaxWaitSeconds = 180 

Config.RobDistance = 3
Config.RobAnimationSeconds = 10

Config.MinMoney = 100
Config.MaxMoney = 500
Config.StolenItems = {
    MaxChance = 40,
    MinChance = 1,
    Items = {{ Name = 'stolen_iphone', Label="Stolen Iphone", ChanceRangeMin = 11, ChanceRangeMax = 20},
    { Name = 'stolen_wallet', Label="Stolen Wallet", ChanceRangeMin = 21, ChanceRangeMax = 40},
    { Name = 'money', ChanceRangeMin = 1, ChanceRangeMax = 10}}
}