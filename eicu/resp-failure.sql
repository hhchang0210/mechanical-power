-- Extracts chronic respiratory impairment and COPD
DROP TABLE IF EXISTS mp_respfailure CASCADE;
CREATE TABLE mp_respfailure as
-- apache admission diagnosis
with rf1 as
(
  select
    patientunitstayid
    , case when apacheadmissiondx in ('Emphysema/bronchitis', '	Restrictive lung disease') then 1 else 0 end
        as respfailure_apachedx
  from patient
)
-- active diagnoses
, rf2 as
(
  select
    patientunitstayid
    , max(case
        when diagnosisstring like 'pulmonary|disorders of the airways|COPD%' then 1
        when diagnosisstring like 'pulmonary|disorders of the airways|acute COPD%' then 1
        when diagnosisstring like 'pulmonary|disorders of lung parenchyma|occupational pulmonary disease%' then 1
      else 0 end) as respfailure_dx
    , max(case
        when diagnosisstring like 'pulmonary|disorders of the airways|COPD%' then 1
        when diagnosisstring like 'pulmonary|disorders of the airways|acute COPD%' then 1
      else 0 end) as copd_dx
    , max(case
        when diagnosisstring = 'burns/trauma|trauma - systemic effects|ARDS' then 1
        when diagnosisstring like 'pulmonary|respiratory failure|ARDS%' then 1
        when diagnosisstring like 'surgery|respiratory failure|ARDS%' then 1
      else 0 end) as ards_dx
)
  from diagnosis
  where diagnosisoffset >= -60 and diagnosisoffset < 60*24
  group by patientunitstayid
)
-- past history
, rf3 as
(
  select
    patientunitstayid
    , max(case when pasthistorypath in
    (
         'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Asthma/asthma'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/COPD/COPD  - moderate'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/COPD/COPD  - no limitations'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/COPD/COPD  - severe'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Home Oxygen/home oxygen'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO <30'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO 31-40'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO 41-50'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO 51-60'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO 61-70'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO 71-80'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/DLCO (%)/DLCO >80'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 <30'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 31-40'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 41-50'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 51-60'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 61-70'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 71-80'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1 (%)/FEV1 >80'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio <30'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio 31-40'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio 41-50'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio 51-60'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio 61-70'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio 71-80'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FEV1/FVC Ratio/FEV1/FVC ratio >80'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC <30'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC 31-40'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC 41-50'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC 51-60'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC 61-70'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC 71-80'
      --  , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Pulmonary Function Tests/FVC (%)/FVC >80'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Respiratory Failure/multiple/multiple'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Respiratory Failure/respiratory failure - date unknown'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Respiratory Failure/respiratory failure - remote'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Respiratory Failure/respiratory failure - within 2 years'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Respiratory Failure/respiratory failure - within 5 years'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Respiratory Failure/respiratory failure - within 6 months'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Restrictive Disease/restrictive pulmonary disease'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/Sarcoidosis/sarcoidosis'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/s/p Lung Transplant/s/p lung transplant'

    ) then 1 else 0 end) as respfailure_pasthistory
    , max(case when pasthistorypath in
    (
         'notes/Progress Notes/Past History/Organ Systems/Pulmonary/COPD/COPD  - moderate'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/COPD/COPD  - no limitations'
       , 'notes/Progress Notes/Past History/Organ Systems/Pulmonary/COPD/COPD  - severe'

    ) then 1 else 0 end) as copd_pasthistory
  from pasthistory
  group by patientunitstayid
)
-- group together all the respiratory failures
select
  pt.patientunitstayid
  , case
      when rf1.respfailure_apachedx = 1 then 1
      when rf2.respfailure_dx = 1 then 1
      when rf3.respfailure_pasthistory = 1 then 1
    else 0 end as respfailure
  , case
      when rf2.ards_dx = 1 then 1
    else 0 end as ards
  , case
      when rf2.copd_dx = 1 then 1
      when rf3.copd_pasthistory = 1 then 1
    else 0 end as copd
from patient pt
left join rf1
  on pt.patientunitstayid = rf1.patientunitstayid
left join rf2
  on pt.patientunitstayid = rf2.patientunitstayid
left join rf3
  on pt.patientunitstayid = rf3.patientunitstayid
order by pt.patientunitstayid;
