Rails.application.config.session_store :active_record_store, :key => '_oms_session', secure: Rails.env.production?, expire_after: 3.days
