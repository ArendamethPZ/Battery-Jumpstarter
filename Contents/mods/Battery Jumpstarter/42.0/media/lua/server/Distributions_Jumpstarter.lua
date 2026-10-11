require 'Items/ProceduralDistributions'
require 'Vehicles/VehicleDistributions'

local ITEM = "Jumpstarter"

local proceduralLoot = {
    CarSupplyTools = 6,
    GarageMechanics = 0.05,
    MechanicShelfElectric = 6,
    MechanicSpecial = 10,
    GigamartTools = 0.05,
}

local vehicleLoot = {
    TrunkStandard = 3,
    TrunkHeavy = 3,
    TrunkSports = 3,
    SurvivalistTruckBed = 3,
    FishermanTruckBed = 3,
    GroceriesTruckBed = 3,
    GolfTruckBed = 3,
    ClothingTruckBed = 3,
    CarpenterTruckBed = 3,
    ElectricianTruckBed = 3,
    FarmerTruckBed = 3,
    MetalWelderTruckBed = 3,
    DoctorTruckBed = 3,
    RadioTruckBed = 3,
    PainterTruckBed = 3,
    ConstructionWorkerTruckBed = 3,
    TaxiTruckBed = 3,
    PoliceTruckBed = 3,
    RangerTruckBed = 3,
    FireTruckBed = 3,
    McCoyTruckBed = 3,
    FossoilTruckBed = 3,
    PostalTruckBed = 3,
    SpiffoTruckBed = 3,
    MassGenFacTruckBed = 3,
    TransitTruckBed = 5,
    DistilleryTruckBed = 3,
    HeraldsTruckBed = 3,
    AmbulanceTruckBed = 3,
}

local function addLoot(distribution, name, weight)
    if not distribution or not distribution.items then
        print("[BatteryJumpstarter] Distribution not found: " .. name)
        return
    end
    table.insert(distribution.items, ITEM)
    table.insert(distribution.items, weight)
end

for name, weight in pairs(proceduralLoot) do
    addLoot(ProceduralDistributions.list[name], name, weight)
end

for name, weight in pairs(vehicleLoot) do
    addLoot(VehicleDistributions[name], name, weight)
end
