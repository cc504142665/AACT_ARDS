DROP MATERIALIZED VIEW IF EXISTS aactards CASCADE;
CREATE MATERIALIZED VIEW aactards as
with 
	cond as (select distinct nct_id, downcase_name, name from ctgov.conditions  
	where downcase_name like '%acute respiratory failure%' or downcase_name like '%acute lung injury%' or 
        downcase_name like '%ALI%' or downcase_name like '%ards%' or downcase_name like '%acute respiratory distress syndrome%' or 
	downcase_name like '%shock lung%' or downcase_name like '%adult respiratory distress syndrome%'),

	designO as (select distinct nct_id, measure, time_frame from ctgov.design_outcomes
			  where outcome_type = 'primary')

select distinct ON (studies.nct_id)
    studies.nct_id, studies.start_month_year, studies.completion_month_year, 
    studies.study_type, studies.official_title, studies.overall_status,
    studies.phase, studies.enrollment, studies.number_of_arms, 

    cond.downcase_name AS conditions,

    facilities.name AS facilities, facilities.state, facilities.country,

    sponsors.name AS sponsors, sponsors.agency_class AS sponsors_class,

    eligibilities.gender, eligibilities.minimum_age, eligibilities.maximum_age, eligibilities.healthy_volunteers,

    calculated_values.number_of_facilities, calculated_values.registered_in_calendar_year,
    calculated_values.were_results_reported, 

    designs.allocation, designs.time_perspective, designs.masking, 
    designs.subject_masked, designs.caregiver_masked, designs.investigator_masked,
    designs.outcomes_assessor_masked,

    interventions.name AS intervention, interventions.intervention_type,

    all_interventions.names AS intervention1, all_intervention_types.names AS intervention_type1,

    all_browse_conditions.names AS browse_conditions,

    all_browse_interventions.names AS browse_interventions,

    all_group_types.names AS group_types,

    designO.measure AS outcomes, 

    all_primary_outcome_measures.names AS primary_outcome,

    outcome_analyses.non_inferiority_type, 

    brief_summaries.description AS summaries

    from studies

    inner join cond on studies.nct_id = cond.nct_id
    left join ctgov.facilities on facilities.nct_id = cond.nct_id
    left join ctgov.sponsors on sponsors.nct_id = cond.nct_id
    left join ctgov.eligibilities on eligibilities.nct_id = cond.nct_id
    left join ctgov.calculated_values on calculated_values.nct_id = cond.nct_id
    left join ctgov.designs on designs.nct_id = cond.nct_id
    left join ctgov.interventions on interventions.nct_id = cond.nct_id
    left join ctgov.all_interventions on all_interventions.nct_id = cond.nct_id
    left join ctgov.all_intervention_types on all_intervention_types.nct_id = cond.nct_id
    left join ctgov.all_browse_conditions on all_browse_conditions.nct_id = cond.nct_id
    left join ctgov.all_browse_interventions on all_browse_interventions.nct_id = cond.nct_id
    left join ctgov.all_group_types on all_group_types.nct_id = cond.nct_id
    left join designO on designO.nct_id = cond.nct_id
    left join ctgov.all_primary_outcome_measures on all_primary_outcome_measures.nct_id = cond.nct_id
    left join ctgov.outcome_analyses on outcome_analyses.nct_id = cond.nct_id
    left join ctgov.brief_summaries on brief_summaries.nct_id = cond.nct_id
    ORDER BY studies.nct_id;
