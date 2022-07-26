local Translations = {
    error = {
        no_vehicles = "Vous n'avez aucun véhicule dans ce garage!",
        not_in_parking = "Pas de véhicule dans le parking ou vous n'êtes jamais monté dedans",
        not_impound = "Votre véhicule n'est pas à la fourrière",
        not_owned = "Le véhicule ne vous appartient pas",
        not_correct_type = "Vous ne pouvez pas stocker ce type de véhicule ici.",
        not_enough = "Pas assez d'argent",
        no_garage = "Aucun",
        no_vehicles_impounded = "Vous n'avez aucun véhicule en fourrière!",
        vehicle_at_depot = "Votre véhicule doit être à la fourrière!",
        impounded_by_police = "Ce véhicule a été mis en fourrière par la police!",
        someone_inside = "Le véhicule n'a pu être rangé, quelqu'un se trouve sans doute dedans.",
    },
    success = {vehicle_parked = "Véhicule garé !", vehicle_out = "Véhicule sorti !"},
    menu = {
        header = {
            house_car = "Garage de propriété %{value}",
            public_car = "Garage Public %{value}",
            public_sea = "Hangar à bateaux Public %{value}",
            public_air = "Hangar Public %{value}",
            job_car = "Garage de fonction %{value}",
            job_sea = "Hangar à bateaux de fonction %{value}",
            job_air = "Hangar de fonction %{value}",
            gang_car = "Garage de Gang %{value}",
            gang_sea = "Hangar à bateaux de Gang %{value}",
            gang_air = "Hangar de Gang %{value}",
            depot_car = "Fourrière %{value}",
            depot_sea = "Fourrière %{value}",
            depot_air = "Fourrière %{value}",
            vehicles = "Véhicules disponibles",
            depot = "%{value} [ %{value2} ] - Coût: $%{value3}",
            public = "%{value} [ %{value2} ]",
            private = "%{value} [ %{value2} ] - Coût: $%{value3}",
            entreprise = "%{value} [ %{value2} ]",
            housing = "%{value} [ %{value2} ]",
        },
        leave = {
            car = "⬅ Quitter le garage",
            sea = "⬅ Quitter le hangar à bateaux",
            air = "⬅ Quitter le Hangar",
            depot = "⬅ Quitter la fourrière",
        },
        text = {
            vehicles = "Voir les véhicules stockés"
        },
    },
    status = {
        out = "Dehors",
        garaged = "Garé dans un parking",
        garagedentre = "Garé dans un parking entreprise",
        impound = "En Fourrière",
    },
    info = {
        car_e = "~g~E~w~ - Garage",
        sea_e = "~g~E~w~ - Hangarà bateaux",
        air_e = "~g~E~w~ - Hangar",
        park_e = "~g~E~w~ - Ranger le véhicule",
        house_garage = "Garage Personnel",
    },
}

Lang = Locale:new({phrases = Translations, warnOnMissing = true})
