# Post-processing updates
library(mongolite)

dotenv::load_dot_env()
con_string <- Sys.getenv("MONGODB_URL_DEV")

pub_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "publications"
)

model_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "models"
)

update_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "update"
)

summary_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "summary"
)

n_models <- model_con$count()
n_pubs <- pub_con$count()

counts <- list(
  "_id" = "counts",
  "models" = n_models,
  "pubs" = n_pubs
) |> jsonlite::toJSON(auto_unbox = TRUE)

summary_con$update(counts, upsert = TRUE)

# Get distinct model types
model_con$distinct("model_type")

# Get distinct countries
country_pipeline <- '[ 
  { "$match": { 
      "descriptors.country": { "$ne": null }
    } 
  },
  { "$unwind": "$descriptors.country" },
  { "$group": { 
      "_id": { 
        "country": "$descriptors.country"
      }
    } 
  },
  { "$project": { 
      "country": "$_id.country", 
      "_id": 0 
    } 
  }
]'

countries <- model_con$aggregate(country_pipeline) |>
  dplyr::left_join(ISOcodes::ISO_3166_1, by = c("country" = "Alpha_2")) |>
  dplyr::select(country, Name) |>
  dplyr::rename(iso = country, name = Name)

countries <- list(
  "_id" = jsonlite::unbox("countries"),
  "iso" = countries$iso,
  "name" = countries$name
) |> jsonlite::toJSON()

summary_con$update(countries, upsert = TRUE)

distinct <- list(
  "_id" = jsonlite::unbox("distinct"),
  "model_type" = model_con$distinct("model_type")
) |> jsonlite::toJSON()

summary_con$update(distinct, upsert = TRUE)

pipeline <- '[ 
  { "$match": { 
      "descriptors.taxa.genus": { "$ne": null }, 
      "descriptors.taxa.species": { "$ne": null } 
    } 
  },
  { "$unwind": "$descriptors.taxa" },
  { "$group": { 
      "_id": { 
        "genus": "$descriptors.taxa.genus", 
        "species": "$descriptors.taxa.species" 
      }
    } 
  },
  { "$project": { 
      "genus": "$_id.genus", 
      "species": "$_id.species", 
      "_id": 0 
    } 
  }
]'

# Run the aggregation query to get distinct genus-species pairings
unique_genus_species <- model_con$aggregate(pipeline)

unique_genus_species$genus[unique_genus_species$genus == "NA"] <- NA
unique_genus_species$species[unique_genus_species$species == "NA"] <- NA

genus_species <- list(
  "_id" = jsonlite::unbox("genus_species"),
  "genus" = unique_genus_species$genus,
  "species" = unique_genus_species$species
) |> jsonlite::toJSON()

summary_con$update(genus_species, upsert = TRUE)