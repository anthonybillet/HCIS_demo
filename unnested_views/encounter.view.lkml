#########  Original Table  #########
# unnested arrays are included as view with their own dimensions below

view: encounter {
  sql_table_name: lookerdata.healthcare_demo_live.encounter ;;

  #########  Standard dimensions  #########

  dimension: id {
    hidden: no
    label: " Encounter ID"
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: status {
    description: "planned | arrived | triaged | in-progress | onleave | finished | cancelled +"
    label: " Status"
    type: string
    sql: ${TABLE}.status ;;
  }


  #########  JSON  dimensions  #########

  ### class fields ###

  dimension: class {
    hidden: yes
    sql: ${TABLE}.class ;;
  }

  dimension: code {
    description: "inpatient | outpatient | ambulatory | emergency +"
    label: "Class Code"
    type: string
    sql: ${class}.code ;;
  }

  dimension: code_name {
    type: string
    sql: case when ${code} = 'IMP' then 'Inpatient'
    when ${code} = 'AMB' then 'Ambulatory'
    when ${code} = 'EMER' then 'Emergency Department' end;;
  }

  dimension: is_inpatient {
    type: yesno
    sql: ${code} = 'IMP';;
  }

  dimension: system {
    hidden: yes
    group_label: "Class"
    type: string
    sql: ${class}.system ;;
  }

  dimension: hospital_concat_date {
    hidden: yes
    type: string
    sql: CONCAT(${organization.name} ,': ', ${period__start_time}) ;;
  }


  ### hospitalization fields ###

  dimension: hospitalization {
    hidden: yes
    sql: ${TABLE}.hospitalization ;;
  }

  #nested json field
  dimension: hospitalization__discharge_disposition {
    hidden: yes
    sql: ${hospitalization}.dischargeDisposition ;;
  }
  #nested array, unnested below
  dimension: hospitalization__discharge_disposition__coding {
    hidden: yes
    sql: ${hospitalization__discharge_disposition}.coding ;;
  }

  ## Readmission - The type of hospital re-admission that has occurred (if any).
  ##If the value is absent, then this is not identified as a readmission
  #nested json field
  dimension: hospitalization__readmission {
    hidden: yes
    sql: ${hospitalization}.readmission ;;
  }
  #nested array, unnested below
  dimension: hospitalization__readmission__coding {
    hidden: yes
    sql: ${hospitalization__readmission}.coding ;;
  }

  ## Admit Source - Where was patient admitted from
  #nested json field
  dimension: hospitalization__admit_source {
    hidden: yes
    sql: ${hospitalization}.admitSource ;;
  }
  #nested array, unnested below
  dimension: hospitalization__admit_source__coding {
    hidden: yes
    sql: ${hospitalization__admit_source}.coding ;;
  }

  ### ORIGIN  -- The location/organization from which the patient came before admission
  #nested json field
  dimension: hospitalization__origin {
    hidden: yes
    sql: ${hospitalization}.origin ;;
  }

  dimension: hospitalization__origin__locationid {
    group_label: "Hospitalization Origin Location"
    label: "Origin ID"
    description: "The location/organization from which the patient came before admission"
    type: string
#     hidden: yes
    sql: ${hospitalization__origin}.locationid ;;
  }

  dimension: hospitalization__origin__reference {
    group_label: "Hospitalization Origin Location"
    label: "Origin Name"
    description: "The location/organization from which the patient came before admission"
    type: string
#     hidden: yes
    sql: ${hospitalization__origin}.reference ;;
  }


  #### period fields ###

  dimension: period {
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension_group: period__end {
    label: "  Discharge"
    type: time
    timeframes: [
      date,
      week,
      month,
      year,
      day_of_week,
      time,
      time_of_day,
      hour_of_day,
      raw
    ]
    sql:  ${period}.end ;;
  }

  dimension_group: period__start {
    label: "   Admission"
    type: time
    timeframes: [
      date,
      week,
      month,
      month_name,
      year,
      day_of_week,
      time,
      time_of_day,
      hour_of_day,
      day_of_year,
      week_of_year,
      raw
    ]
    sql: ${period}.start ;;
  }

  dimension: length_of_stay {
    type: duration_minute
    sql_start: ${period__start_raw} ;;
    sql_end: ${period__end_raw} ;;
  }


  ### metadata fields ###

  dimension: meta {
    hidden: yes
    sql: ${TABLE}.meta ;;
  }

  #nested array, unnested below
  dimension: meta__profile {
    hidden: yes
    type: string
    sql: ${meta}.profile ;;
  }


  #### service provider fields  ####

  dimension: service_provider {
    hidden: yes
    sql: ${TABLE}.serviceProvider ;;
  }

  dimension: organization_id {
    hidden: no
    label: " Organization ID"
    description: "Service Provider Organization ID"
    type: string
    sql: ${service_provider}.organizationId ;;
    link: {
      label: "Operations Overview for Hospital"
      url: "/dashboards/273?Hospital%20ID={{ value }}"
      icon_url: "https://avatars0.githubusercontent.com/u/1437874?s=400&v=4"
    }
  }

  #### subject fields  ####

  dimension: subject {
    hidden: yes
    sql: ${TABLE}.subject ;;
  }

  dimension: patient_id {
    hidden: no
    label: " Patient ID"
    sql: ${subject}.patientId ;;
  }


  #########  Array  dimensions, unnested below  #########

  dimension: participant {
    hidden: yes
    sql: ${TABLE}.participant ;;
  }

  dimension: reason {
    hidden: yes
    sql: ${TABLE}.reason ;;
  }

  dimension: location {
    hidden: yes
    sql: ${TABLE}.location ;;
  }

  dimension: type {
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  #########  Measures  #########

  measure: count {
    label: "Number of Encounters"
    type: count
    drill_fields: [encounter__type__coding.display, average_los]
  }
  measure: average_los {
    label: "Average Length of Stay"
    type: average
    sql: ${length_of_stay} ;;
    value_format_name: decimal_2
    drill_fields: [organization_id, average_los]
  }
  measure: min_los {
    group_label: "LOS Statistics"
    label: "Min Length of Stay"
    type: min
    sql: ${length_of_stay} ;;
    value_format_name: decimal_2
  }
  measure: max_los {
    group_label: "LOS Statistics"
    label: "Max Length of Stay"
    type: max
    sql: ${length_of_stay} ;;
    value_format_name: decimal_2
  }
  measure: 25_los {
    group_label: "LOS Statistics"
    label: "25th Percentile Length of Stay"
    type: percentile
    percentile: 25
    sql: ${length_of_stay} ;;
    value_format_name: decimal_2
  }
  measure: 75_los {
    group_label: "LOS Statistics"
    label: "75th Percentile Length of Stay"
    type: percentile
    percentile: 75
    sql: ${length_of_stay} ;;
    value_format_name: decimal_2
  }
  measure: med_los {
    group_label: "LOS Statistics"
    label: "Median Length of Stay"
    type: median
    sql: ${length_of_stay} ;;
    value_format_name: decimal_2
  }
  measure: count_patients {
    label: "Number of Patients"
    type: count_distinct
    sql: ${patient_id} ;;
    drill_fields: [patient_id, patient.gender, patient.age, patient.los]
  }

  measure: repeat_patients {
    label: "Percent of Repeat Patients"
    type: number
    value_format_name: percent_2
    sql: 1.0*(${count}-${count_patients})/nullif(${count},0) ;;
  }

  measure: latest_encounter {
    type: date_time
    sql: MAX(${period__start_raw}) ;;
  }

  measure: recent_visits {
    type: string
    sql: STRING_AGG(${hospital_concat_date}, " ; " LIMIT 3) ;;
  }
}

#########  Unnested Arrays  #########

### arrays with nested JSON ###
view: encounter__hospitalization__discharge_disposition__coding {
  label: "Encounter"

  dimension: code {
    group_label: "Discharge"
    description: "Code - Category or kind of location after discharge"
    label: "Discharge Code"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: is_discharged {
    type: yesno
    sql: ${code} is not null ;;
  }
  dimension: display {
    group_label: "Discharge"
    label: "Discharge Disposition"
    description: "Name - Category or kind of location after discharge"
    type: string
    sql: ${TABLE}.display ;;
    link: {
      label: "Look up on NUBC"
      icon_url: "http://www.healthforum.com/images/billing-coding/nubc-logo.png"
      url: "{{ encounter.system._value }}"
    }
  }
  dimension: system {
    hidden: yes
    group_label: "Discharge"
    type: string
    sql: ${TABLE}.system ;;
  }
}

### arrays with nested JSON ###
view: encounter__hospitalization__readmission__coding {
  label: "Encounter"
  dimension: code {
    group_label: "Readmission"
    description: "The type of hospital re-admission that has occurred (if any). If the value is absent, then this is not identified as a readmission"
    label: "Code"
    type: string
    sql: ${TABLE}.code ;;
  }
  dimension: display {
    group_label: "Readmission"
    description: "The type of hospital re-admission that has occurred (if any). If the value is absent, then this is not identified as a readmission"
    label: "Name"
    type: string
    sql: ${TABLE}.display ;;
  }
}

### arrays with nested JSON ###
view: encounter__hospitalization__admit_source__coding {
  label: "Encounter"
  dimension: code {
    group_label: "Admit Source"
    description: "From where patient was admitted (physician referral, transfer)"
    label: "Code"
    type: string
    sql: ${TABLE}.code ;;
  }
  dimension: display {
    group_label: "Admit Source"
    description: "From where patient was admitted (physician referral, transfer)"
    label: "Name"
    type: string
    sql: ${TABLE}.display ;;
  }
}

view: encounter__location {
  label: "Encounter"
  dimension: location {
    hidden: yes
    sql: ${TABLE}.location;;
  }
  dimension: location_id {
    group_label: "Location"
    type: string
    sql: ${location}.locationid ;;
  }
  dimension: reference {
    group_label: "Location"
    type: string
    sql: ${location}.reference ;;
  }
}

view: encounter__participant {
  label: "Encounter"
  dimension: primary_key {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${encounter.id},${practitionerId});;
  }

  ### individual fields ###
  dimension: individual {
    hidden: yes
    sql: ${TABLE}.individual ;;
  }

  dimension: practitionerId {
    hidden: no
    label: " Practitioner ID"
    sql: ${individual}.practitionerId ;;
  }

  measure: number_of_participants {
    type: count
    label: "Number of Practicioners"
    hidden: yes
  }
}

view: encounter__type {
  label: "Encounter"
  dimension: coding {
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    hidden: yes
    group_label: "Type"
    type: string
    sql: ${TABLE}.text ;;
  }
}


#nested array inside encounter.type
view: encounter__type__coding {
  label: "Encounter"
  dimension: code {
    group_label: "Type"
    label: "Type Code"
    description: "Code - Specific type of encounter"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "Type"
    label: "Type"
    description: "Name - Specific type of encounter"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: is_wellness_screening {
    type: yesno
    sql: ${display} IN ('Encounter for \'check-up\'', 'Encounter for check up', 'Encounter for check up (procedure)')  ;;
  }

  dimension: system {
    group_label: "Type"
    hidden: yes
    type: string
    sql: ${TABLE}.system ;;
  }

}

view: encounter__reason {
  dimension: coding {
    hidden: yes
    sql: ${TABLE}.coding ;;
  }
}

#nested array inside encounter.reason
view: encounter__reason__coding {
  label: "Encounter"
  dimension: code {
    group_label: "Reason"
    label: "Reason Code"
    description: "Coded reason the encounter takes place"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: is_covid_flag {
    type: yesno
    sql: ${code} in ('65710008', '195967001', '233678006', '185086009', '233604007') ;;
  }

  dimension: display {
    group_label: "Reason"
    label: "Reason"
    description: "Coded reason the encounter takes place"
    type: string
    sql: ${TABLE}.display ;;
    link: {
      label: "Look up on Snomed"
      icon_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSP9Q4u6D3vfBt1K_VVcso-bjl6hRAhOEBAF0kLE_haQDD-f0-7&s"
      url: "{{ encounter.system._value }}"
    }
  }
  dimension: system {
    hidden: yes
    type: string
    sql: ${TABLE}.system ;;
  }
}

############################

### arrays without nested fields ###
view: encounter__meta__profile {
  label: "Encounter"

  dimension: profile {
    hidden: yes
    label: " Profile"
    sql: ${TABLE} ;;
  }
}
